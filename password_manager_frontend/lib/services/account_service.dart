import '../models/account.dart';
import 'base_service.dart';


/// AccountService
/// Метод fetchAccountById(int id):
/// - Делает GET на /accounts/{id}.
/// - Возвращает Account из JSON.
class AccountService extends BaseService {
  Future<Account> fetchAccountById (int id) async {
    final jsonData = await get ('/accounts/$id');
    print("DEBUG raw JSON from /accounts/$id: $jsonData");
    return Account.fromJson(jsonData);
  }
}