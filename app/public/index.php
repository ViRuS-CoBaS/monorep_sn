<?php

use App\Shared\Kernel;

require_once dirname(__DIR__) . '/vendor/autoload_runtime.php';

return function (array $context) {
    file_put_contents('./file.txt', print_r($_SERVER, true));
    return new Kernel($context['APP_ENV'], (bool)$context['APP_DEBUG']);
};
