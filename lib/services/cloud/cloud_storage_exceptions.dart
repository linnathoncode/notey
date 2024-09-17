class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotGetAllException extends CloudStorageException {}

class CouldNotUpdateException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}
