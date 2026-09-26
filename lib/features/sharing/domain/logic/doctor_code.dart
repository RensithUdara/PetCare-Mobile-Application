/// Normalises what the owner typed into a doctor code like `DR-7K3M9Q`,
/// or returns `null` if it can't be one. Accepts lower case, spaces, and a
/// missing `DR-` prefix.
String? normalizeDoctorCode(String input) {
  var code = input.toUpperCase().replaceAll(RegExp(r'[\s_]'), '');
  if (code.startsWith('DR-')) {
    code = code.substring(3);
  } else if (code.startsWith('DR')) {
    code = code.substring(2);
  }
  code = code.replaceAll('-', '');
  if (!RegExp(r'^[A-HJ-NP-Z2-9]{6}$').hasMatch(code)) return null;
  return 'DR-$code';
}
