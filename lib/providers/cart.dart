import 'package:flutter/material.dart';
import 'package:shoes_shop/constants/enums/quantity_operation.dart';

import '../models/cart.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, Cart> _cartItems = {};

  Map<String, Cart> get getCartItems => {..._cartItems};

  get getCartQuantity => _cartItems.isEmpty ? 0 : getCartItems.length;

  bool isItemEmpty() => _cartItems.isEmpty ? true : false;

  double getCartTotalAmount() {
    double totalAmount = 0.0;

    _cartItems.forEach((key, value) {
      totalAmount += value.price * value.quantity;
    });

    return totalAmount;
  }

  int getProductQuantityOnCart(String prodId) {
    int quantity = 0;
    _cartItems.forEach((key, value) {
      if (key == prodId) {
        quantity += value.quantity;
      }
    });

    return quantity;
  }

  void increaseQuantity(String prodId) {
    _cartItems.forEach((key, value) {
      if (key == prodId) {
        value.increaseQuantity();
      }
    });
    notifyListeners();
  }

  void decreaseQuantity(String prodId) {
    _cartItems.forEach((key, value) {
      if (key == prodId) {
        if (value.quantity > 1) {
          value.decreaseQuantity();
        }
      }
    });
    notifyListeners();
  }

  void toggleQuantity(QuantityOperation operation, String cartId) {
    switch (operation) {
      case QuantityOperation.increment:
        _cartItems.update(
          cartId,
          (existingCartItem) => Cart(
            cartId: existingCartItem.cartId,
            prodName: existingCartItem.prodName,
            prodImg: existingCartItem.prodImg,
            prodId: existingCartItem.prodId,
            vendorId: existingCartItem.vendorId,
            quantity: existingCartItem.quantity + 1,
            prodSize: existingCartItem.prodSize,
            price: existingCartItem.price,
            date: existingCartItem.date,
          ),
        );
        break;

      case QuantityOperation.decrement:
        _cartItems.update(
          cartId,
          (existingCartItem) => Cart(
            cartId: existingCartItem.cartId,
            prodId: existingCartItem.prodId,
            prodName: existingCartItem.prodName,
            prodImg: existingCartItem.prodImg,
            vendorId: existingCartItem.vendorId,
            quantity: existingCartItem.quantity - 1,
            prodSize: existingCartItem.prodSize,
            price: existingCartItem.price,
            date: existingCartItem.date,
          ),
        );
        break;
    }
    notifyListeners();
  }

  bool isItemOnCart(String prodId) => _cartItems.containsKey(prodId);

  void addToCart(Cart cartItem) {
    if (isItemOnCart(cartItem.prodId)) {
      _cartItems.update(
        cartItem.cartId,
        (existingCartItem) => Cart(
          cartId: existingCartItem.cartId,
          prodId: existingCartItem.prodId,
          prodName: existingCartItem.prodName,
          prodImg: existingCartItem.prodImg,
          vendorId: existingCartItem.vendorId,
          quantity: existingCartItem.quantity + 1,
          prodSize: existingCartItem.prodSize,
          price: existingCartItem.price,
          date: existingCartItem.date,
        ),
      );
    } else {
      _cartItems.putIfAbsent(cartItem.prodId, () => cartItem);
    }
    notifyListeners();
  }

  void removeFromCart(String prodId) {
    _cartItems.remove(prodId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // New method to update quantity directly
  void updateQuantity(String prodId, int newQuantity) {
    _cartItems.update(
      prodId,
      (existingCartItem) => Cart(
        cartId: existingCartItem.cartId,
        prodId: existingCartItem.prodId,
        prodName: existingCartItem.prodName,
        prodImg: existingCartItem.prodImg,
        vendorId: existingCartItem.vendorId,
        quantity: newQuantity,
        prodSize: existingCartItem.prodSize,
        price: existingCartItem.price,
        date: existingCartItem.date,
      ),
    );
    notifyListeners();
  }
}
