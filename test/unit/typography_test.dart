import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/tokens.dart';

void main() {
  test('secondary text stays readable for CJK content', () {
    expect(AppTextStyles.caption.fontSize, greaterThanOrEqualTo(12));
    expect(AppTextStyles.bodyS.fontSize, greaterThanOrEqualTo(13));
    expect(AppTextStyles.bodyS.height, greaterThanOrEqualTo(1.4));
    expect(AppTextStyles.label.fontSize, greaterThanOrEqualTo(13));
  });
}
