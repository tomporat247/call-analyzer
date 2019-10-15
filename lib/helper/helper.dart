formatPhoneNumber(String phoneNumber) {
  return phoneNumber == null ? null : phoneNumber.replaceAll('-', '');
}