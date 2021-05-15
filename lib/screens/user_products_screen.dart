import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routesName = "/user-products";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('your product'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routesName),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (BuildContext context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                child: Consumer<Products>(
                  builder: (context, productsData, child) => Padding(
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (BuildContext context, int index) => Column(
                        children: [
                          UserProductItem(
                            id: productsData.items[index].id,
                            title: productsData.items[index].title,
                            imageUrl: productsData.items[index].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
                onRefresh: () => _refreshProduct(context),
              ),
      ),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }
}
