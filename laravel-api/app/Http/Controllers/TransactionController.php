<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
            'payment_method' => 'nullable|in:cash,card,qris',
            'payment_status' => 'nullable|in:paid,pending',
        ]);

        $query = Transaction::with(['user', 'customer', 'items.product']);

        if ($request->date_from) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->date_to) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }
        if ($request->payment_method) {
            $query->where('payment_method', $request->payment_method);
        }
        if ($request->payment_status) {
            $query->where('payment_status', $request->payment_status);
        }

        $perPage = min($request->integer('per_page', 20), 100);
        $transactions = $query->latest()->paginate($perPage);
        return response()->json($transactions);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'customer_id' => 'nullable|exists:customers,id',
            'payment_method' => 'required|in:cash,card,qris',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        try {
            $result = DB::transaction(function () use ($request) {
                $total = 0;
                $items = [];

                foreach ($request->items as $item) {
                    $product = Product::where('id', $item['product_id'])->lockForUpdate()->firstOrFail();

                    if ($product->stock < $item['quantity']) {
                        throw new \Exception("Insufficient stock for product: {$product->name}");
                    }

                    $subtotal = $product->price * $item['quantity'];
                    $total += $subtotal;

                    $items[] = [
                        'product_id' => $product->id,
                        'quantity' => $item['quantity'],
                        'price' => $product->price,
                        'subtotal' => $subtotal,
                    ];

                    $product->decrement('stock', $item['quantity']);
                }

                $invoice = 'INV-' . now()->format('YmdHis') . '-' . strtoupper(substr(uniqid(), -5));

                $transaction = Transaction::create([
                    'invoice_number' => $invoice,
                    'user_id' => auth('api')->id(),
                    'customer_id' => $request->customer_id,
                    'total' => $total,
                    'payment_method' => $request->payment_method,
                    'payment_status' => 'paid',
                ]);

                $transaction->items()->createMany($items);

                return $transaction->load(['items.product', 'user', 'customer']);
            });

            return response()->json($result, 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    public function show(Transaction $transaction): JsonResponse
    {
        return response()->json($transaction->load(['items.product', 'user', 'customer']));
    }
}
