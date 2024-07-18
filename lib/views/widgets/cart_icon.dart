// import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_shop/views/customer/cart/cart.dart';

import '../../constants/color.dart';
import '../../providers/cart.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);

    return GestureDetector(
      onTap: () {
        // Navigate to the desired screen when the cart icon is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CartScreen(), // Replace YourNextScreen with the actual screen you want to navigate to
          ),
        );
      },
      child: Badge(
        backgroundColor: Colors.white,
        label: Text(
          '${cartProvider.getCartQuantity}',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        child: const Icon(
          Icons.shopping_cart,
          color: accentColor,
        ),
      ),
    );
  }
}
