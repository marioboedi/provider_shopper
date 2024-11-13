// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalog.dart';

class CartModel extends ChangeNotifier {
  late CatalogModel _catalog;

  // Internal, private state of the cart. Stores the ids of each item.
  final List<int> _itemIds = [];

  CartModel() {
    load();
  }

  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    notifyListeners();
  }

  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  void add(Item item) {
    _itemIds.add(item.id);
    notifyListeners();
    save();
  }

  void remove(Item item) {
    _itemIds.remove(item.id);
    notifyListeners();
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart_items', _itemIds.map((id) => id.toString()).toList());
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final itemIds = prefs.getStringList('cart_items') ?? [];
    _itemIds.clear();
    _itemIds.addAll(itemIds.map(int.parse));
    notifyListeners();
  }
}
