<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\LevelSetList;

return static function (RectorConfig $rectorConfig): void {
    $rectorConfig->paths([
        __DIR__ . '/src',
        __DIR__ . '/tests',  // Опционально для тестов
    ]);

    // Базовые наборы для PHP 8.4+
    $rectorConfig->sets([
        LevelSetList::UP_TO_PHP_84,
    ]);
    $rectorConfig->withComposerBased(symfony: true);
    // Опционально: Исключения для избежания ложных срабатываний
    $rectorConfig->skip([
        // Примеры: Rector\Symfony\Rector\Class_\AddRouteAnnotationRector::class,
    ]);
};
