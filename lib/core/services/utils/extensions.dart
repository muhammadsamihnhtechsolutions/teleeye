extension InputValidation on String {
  dynamic isCorrectNumber({
    required bool cannotBeEmpty,
  }) {
    if (isEmpty && cannotBeEmpty) {
      return '*Field cannot be empty!';
    }
    try {
      double.parse(this);
    } catch (err) {
      return 'Enter valid amount!';
    }
    return null;
  }

  dynamic isCorrectEmailAddress({
    required bool cannotBeEmpty,
  }) {
    if (isEmpty && cannotBeEmpty) {
      return 'Email required';
    }
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
            r'{0,253}[a-zA-Z0-9])?(?:\'
            '.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*')
        .hasMatch(this)) {
      return 'Enter valid email';
    }
    return null;
  }

  dynamic isNotEmpty() {
    if (isEmpty) {
      return '*This field cannot be empty!';
    }
    return null;
  }

  dynamic isCorrectName() {
    if (isEmpty) {
      return 'Username required';
    }
    if (!RegExp(r"^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$").hasMatch(this)) {
      return 'Enter valid username';
    }
    return null;
  }
}

String capitalizeFirstWord(String input) {
  if (input.isEmpty) {
    return input;
  }

  return input[0].toUpperCase() + input.substring(1);
}
