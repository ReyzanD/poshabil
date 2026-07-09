<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Customer;
use App\Models\Product;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function stats(): JsonResponse
    {
        return response()->json([
            'total_products' => Product::count(),
            'total_categories' => Category::count(),
            'total_customers' => Customer::count(),
            'total_transactions' => Transaction::count(),
            'today_revenue' => Transaction::whereDate('created_at', today())
                ->where('payment_status', 'paid')
                ->sum('total'),
            'monthly_revenue' => Transaction::whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->where('payment_status', 'paid')
                ->sum('total'),
            'recent_transactions' => Transaction::with(['user', 'customer'])
                ->latest()
                ->take(5)
                ->get(),
        ]);
    }
}
