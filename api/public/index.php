<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use App\Application;
use DI\ContainerBuilder;

$containerBuilder = new ContainerBuilder();

$container = $containerBuilder->build();

$app = $container->get(Application::class);

$app->run();
