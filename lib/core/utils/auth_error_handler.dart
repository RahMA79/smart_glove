/// Translates raw Supabase/Auth error messages into human-friendly strings.
String friendlyAuthError(String raw) {
  final msg = raw.toLowerCase();

  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid credentials') ||
      msg.contains('wrong password') ||
      msg.contains('email not confirmed') == false &&
          msg.contains('invalid')) {
    return 'Email or password is incorrect. Please try again.';
  }
  if (msg.contains('user not found') || msg.contains('no user found')) {
    return 'This email is not registered. Please sign up first.';
  }
  if (msg.contains('email already') ||
      msg.contains('already registered') ||
      msg.contains('already in use')) {
    return 'This email is already registered. Please log in instead.';
  }
  if (msg.contains('invalid email') || msg.contains('email format')) {
    return 'Please enter a valid email address.';
  }
  if (msg.contains('password') && msg.contains('short')) {
    return 'Password must be at least 6 characters.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Please check your inbox and confirm your email first.';
  }
  if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
    return 'Network error. Please check your internet connection.';
  }
  if (msg.contains('too many requests') || msg.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (msg.contains('weak password')) {
    return 'Password is too weak. Use at least 6 characters with letters and numbers.';
  }
  // fallback — still better than raw technical text
  return 'Something went wrong. Please try again.';
}
