import 'dart:typed_data';

/// What the user did to a pet's photo while editing.
sealed class PhotoChange {
  const PhotoChange();
}

class PhotoUnchanged extends PhotoChange {
  const PhotoUnchanged();
}

class PhotoReplaced extends PhotoChange {
  const PhotoReplaced(this.bytes);

  /// Already downscaled / compressed JPEG bytes.
  final Uint8List bytes;
}

class PhotoRemoved extends PhotoChange {
  const PhotoRemoved();
}
