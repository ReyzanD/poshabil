<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Customer;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin',
            'email' => 'admin@pos.test',
            'password' => 'password',
            'role' => 'admin',
        ]);

        User::create([
            'name' => 'Cashier',
            'email' => 'cashier@pos.test',
            'password' => 'password',
            'role' => 'cashier',
        ]);

        $categories = [
            ['name' => 'Makanan', 'description' => 'Makanan ringan dan berat'],
            ['name' => 'Minuman', 'description' => 'Minuman segar dan hangat'],
            ['name' => 'Snack', 'description' => 'Camilan dan kudapan'],
        ];

        foreach ($categories as $cat) {
            Category::create($cat);
        }

        $products = [
            ['category_id' => 1, 'name' => 'Nasi Goreng', 'sku' => 'FOOD-001', 'price' => 25000, 'stock' => 50, 'description' => 'Nasi goreng spesial'],
            ['category_id' => 1, 'name' => 'Mie Goreng', 'sku' => 'FOOD-002', 'price' => 20000, 'stock' => 50, 'description' => 'Mie goreng spesial'],
            ['category_id' => 1, 'name' => 'Ayam Geprek', 'sku' => 'FOOD-003', 'price' => 30000, 'stock' => 40, 'description' => 'Ayam geprek sambal bawang'],
            ['category_id' => 2, 'name' => 'Es Teh', 'sku' => 'DRINK-001', 'price' => 5000, 'stock' => 100, 'description' => 'Es teh manis segar'],
            ['category_id' => 2, 'name' => 'Kopi Hitam', 'sku' => 'DRINK-002', 'price' => 10000, 'stock' => 80, 'description' => 'Kopi hitam pilihan'],
            ['category_id' => 2, 'name' => 'Jus Jeruk', 'sku' => 'DRINK-003', 'price' => 12000, 'stock' => 60, 'description' => 'Jus jeruk peras segar'],
            ['category_id' => 3, 'name' => 'Kentang Goreng', 'sku' => 'SNACK-001', 'price' => 15000, 'stock' => 70, 'description' => 'Kentang goreng crispy'],
            ['category_id' => 3, 'name' => 'Pisang Goreng', 'sku' => 'SNACK-002', 'price' => 10000, 'stock' => 60, 'description' => 'Pisang goreng keju'],
            ['category_id' => 3, 'name' => 'Puding', 'sku' => 'SNACK-003', 'price' => 8000, 'stock' => 40, 'description' => 'Puding coklat'],
        ];

        foreach ($products as $prod) {
            Product::create($prod);
        }

        Customer::create([
            'name' => 'Umum',
            'email' => null,
            'phone' => null,
            'address' => null,
        ]);

        Customer::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'phone' => '081234567890',
            'address' => 'Jl. Merdeka No. 1, Jakarta',
        ]);
    }
}
