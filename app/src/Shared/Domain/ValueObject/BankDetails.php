<?php

namespace App\Shared\Domain\ValueObject;

use InvalidArgumentException;

final class BankDetails
{
    public function __construct(
        private readonly string $bankName,
        private readonly string $accountNumber,
        private readonly string $bic,
        private readonly string $inn,
    )
    {
        $this->validate();
    }

    // Валидация (Domain rules: форматы для РФ, например)
    private function validate(): void
    {
        if (empty($this->bankName) || strlen($this->bankName) > 255) {
            throw new InvalidArgumentException('Наименование банка не может быть пустым.');
        }

        if (!mb_ereg('^\\d{20}$', $this->accountNumber)) {// Пример для рублёвого счёта РФ
            throw new InvalidArgumentException('Некорректный Л/С');
        }

        if (!mb_ereg('^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$', $this->bic)) {// BIC/SWIFT формат
            throw new InvalidArgumentException('Некорректный БИК банка.');
        }

        if (!mb_ereg('^\\d{10}$|^\\d{12}$', $this->inn)) { // ИНН РФ (10/12 цифр)
            throw new InvalidArgumentException('Некорректный ИНН банка.');
        }
    }

    // Геттеры (public readonly — immutable)
    public function getBankName(): string
    {
        return $this->bankName;
    }

    public function getAccountNumber(): string
    {
        return $this->accountNumber;
    }

    public function getBic(): string
    {
        return $this->bic;
    }

    public function getInn(): string
    {
        return $this->inn;
    }

    // Бизнес-методы (пример: форматирование для чека)
    public function formatForPayment(): string
    {
        return sprintf(
            '%s | Account: %s | BIC: %s | INN: %s',
            $this->bankName,
            $this->accountNumber,
            $this->bic,
            $this->inn
        );
    }

    // Equality (VO сравниваются по значению)
    public function equals(BankDetails $other): bool
    {
        return $this->bankName === $other->bankName
            && $this->accountNumber === $other->accountNumber
            && $this->bic === $other->bic
            && $this->inn === $other->inn;
    }

    public function toArray(): array
    {
        return [
            'bankName' => $this->bankName,
            'accountNumber' => $this->accountNumber,
            'bic' => $this->bic,
            'inn' => $this->inn,
        ];
    }

    public static function fromArray(array $data): self
    {
        return new self(
            $data['bankName'],
            $data['accountNumber'],
            $data['bic'],
            $data['inn']
        );
    }
}
