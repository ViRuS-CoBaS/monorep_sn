<?php

namespace App\Application\Http;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'app_default')]
    public function index()
    {
        return $this->json(['data' => 'sucess']);
    }
}
