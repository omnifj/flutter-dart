// ============================================================
// 文件：test/unit/counter_test.dart
// 说明：纯 Dart 单元测试 —— 测试不依赖界面的业务逻辑。
// 被测对象：lib/02_intermediate/01_change_notifier.dart 的 CartModel。
// 运行：flutter test test/unit/counter_test.dart
// ============================================================
import 'package:flutter_dart/02_intermediate/01_change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group 把相关用例组织在一起，报告里更清晰
  group('CartModel 购物车模型', () {
    test('初始为空', () {
      final cart = CartModel();
      expect(cart.totalCount, 0);
      expect(cart.items, isEmpty);
    });

    test('add 增加商品并广播通知', () {
      final cart = CartModel();
      var notified = 0;
      cart.addListener(() => notified++); // 验证 notifyListeners 被调用

      cart.add('苹果');
      cart.add('香蕉');

      expect(cart.totalCount, 2);
      expect(cart.items, ['苹果', '香蕉']);
      expect(notified, 2); // 每次变更都应广播一次
    });

    test('removeAt 删除指定商品', () {
      final cart = CartModel()
        ..add('苹果')
        ..add('香蕉');
      cart.removeAt(0);
      expect(cart.items, ['香蕉']);
    });

    test('clear 清空购物车', () {
      final cart = CartModel()..add('苹果');
      cart.clear();
      expect(cart.items, isEmpty);
    });

    test('外部不能通过 items 直接修改数据', () {
      final cart = CartModel()..add('苹果');
      // items 返回的是只读视图，尝试修改应抛异常
      expect(() => cart.items.add('黑客商品'), throwsUnsupportedError);
    });
  });
}
