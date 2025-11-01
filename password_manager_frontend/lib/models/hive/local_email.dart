import 'package:hive/hive.dart';

part 'local_email.g.dart';

@HiveType(typeId: 0)
class LocalEmail {
  @HiveField(0) int id; // server ID (0 если локально создан)
  @HiveField(1) String localId; // UUID
  @HiveField(2) String emailAddress;
  @HiveField(3) String encryptedPassword;
  @HiveField(4) String? description;
  @HiveField(5) int accountId;
  @HiveField(6) int? categoryId;
  @HiveField(7) int? userId;
  @HiveField(8) String syncStatus; // 'synced', 'pending_create', 'pending_update', 'conflict'
  @HiveField(9) DateTime lastModifiedLocal;
  @HiveField(10) DateTime? lastModifiedServer;

  LocalEmail({
    required this.id,
    required this.localId,
    required this.emailAddress,
    required this.encryptedPassword,
    this.description,
    required this.accountId,
    this.categoryId,
    this.userId,
    this.syncStatus = 'pending_create',
    required this.lastModifiedLocal,
    this.lastModifiedServer,
  });

  // Конвертация из Email (frontend model)
  factory LocalEmail.fromEmailModel(dynamic emailModel) {
    return LocalEmail(
      id: emailModel.id,
      localId: emailModel.id == 0 ? DateTime.now().microsecondsSinceEpoch.toString() : emailModel.id.toString(),
      emailAddress: emailModel.emailAddress,
      encryptedPassword: emailModel.rawPassword, // ⚠️ rawPassword здесь — зашифрованный!
      description: emailModel.emailDescription,
      accountId: emailModel.accountId,
      categoryId: emailModel.categoryId,
      userId: emailModel.userId,
      syncStatus: emailModel.id == 0 ? 'pending_create' : 'synced',
      lastModifiedLocal: DateTime.now(),
      lastModifiedServer: null,
    );
  }

  // Обновление из серверной версии
  void updateFromServer(Map<String, dynamic> serverData) {
    id = serverData['id'];
    encryptedPassword = serverData['encrypted_password'];
    description = serverData['email_description'];
    categoryId = serverData['category_id'];
    lastModifiedServer = DateTime.tryParse(serverData['updated_at'] ?? '') ?? DateTime.now();
    syncStatus = 'synced';
  }
}