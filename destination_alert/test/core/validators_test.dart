import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail handles required and format rules', () {
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail('   '), 'Email address is required');
      expect(
        Validators.validateEmail('notanemail'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('user@'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('user@domain'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('user@domain.c'),
        'Please enter a valid email address',
      );
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(
        Validators.validateEmail('   user.name+tag@domain.co.uk   '),
        isNull,
      );
    });

    test('validatePassword enforces minLength and required checks', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(
        Validators.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('strongPassword123!'), isNull);
    });

    test('validateName enforces required and length checks', () {
      expect(Validators.validateName(null), 'Full name is required');
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateName(' '), 'Full name is required');
      expect(
        Validators.validateName('A'),
        'Name must be at least 2 characters',
      );
      expect(Validators.validateName('Al'), isNull);
      expect(Validators.validateName('Jane Doe'), isNull);
    });

    test('validateConfirmPassword checks matching passwords', () {
      expect(
        Validators.validateConfirmPassword(null, 'secret'),
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword('', 'secret'),
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword('wrong', 'secret'),
        'Passwords do not match',
      );
      expect(Validators.validateConfirmPassword('secret', 'secret'), isNull);
    });

    test('validatePhone handles optional and formatted inputs', () {
      expect(Validators.validatePhone(null, required: false), isNull);
      expect(Validators.validatePhone('', required: false), isNull);
      expect(Validators.validatePhone('   ', required: false), isNull);
      expect(
        Validators.validatePhone(null, required: true),
        'Phone number is required',
      );
      expect(
        Validators.validatePhone('abc', required: false),
        'Please enter a valid phone number',
      );
      expect(Validators.validatePhone('+1 (555) 123-4567'), isNull);
      expect(Validators.validatePhone('1234567890'), isNull);
    });
  });
}
