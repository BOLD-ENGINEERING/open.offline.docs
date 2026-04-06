<?php

declare(strict_types=1);

namespace App;

use Slim\Factory\AppFactory;
use Slim\Interfaces\RouteCollectorProxyInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class Application
{
    private $app;

    public function __construct()
    {
        $app = AppFactory::create();
        
        $this->registerRoutes($app);
        
        $this->app = $app;
    }

    private function registerRoutes($app): void
    {
        $app->get('/', function (Request $request, Response $response) {
            $response->getBody()->write(json_encode([
                'service' => 'open-offline-docs-api',
                'version' => '1.0.0',
                'status' => 'running'
            ]));
            return $response->withHeader('Content-Type', 'application/json');
        });

        $app->get('/docs', [DocsController::class, 'list']);
        $app->post('/docs/{name}/start', [DocsController::class, 'start']);
        $app->post('/docs/{name}/stop', [DocsController::class, 'stop']);
        $app->get('/docs/{name}/status', [DocsController::class, 'status']);
    }

    public function run(): void
    {
        $this->app->run();
    }
}
