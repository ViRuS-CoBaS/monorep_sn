<?php

namespace App\Shared\Application;

use Symfony\Component\Messenger\HandleTrait;
use Symfony\Component\Messenger\MessageBusInterface;

class QueryBus
{
    use HandleTrait;

    public function __construct(
        private readonly MessageBusInterface $bus,
    )
    {
        $this->messageBus = $this->bus;
    }

    public function getMessageBus(): MessageBusInterface
    {
        return $this->messageBus;
    }

    /**
     * @template T
     * @param object $query
     * @return T
     */
    public function query(object $query): mixed
    {
        return $this->handle($query);
    }
}
