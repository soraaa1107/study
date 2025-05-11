public with sharing class AccountDataHandler {

    public static void enrichAccountData(List<Account> accounts) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : accounts) {
            // API連携
            String companyName = acc.Name;
            String address = acc.BillingAddress != null ? acc.BillingAddress.street + ', ' + acc.BillingAddress.city + ', ' + acc.BillingAddress.state + ', ' + acc.BillingAddress.country : null;
            String phone = acc.Phone;

            HttpResponse res = CompanyDataApiClient.fetchCompanyData(companyName, address, phone);

            if (res != null && res.getStatusCode() == 200) {
                // APIからのレスポンスを解析
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                // レスポンスデータから必要な情報を取得し、取引先レコードに反映
                if (responseData != null && responseData.containsKey('matchedCompany')) {
                    Map<String, Object> matchedCompany = (Map<String, Object>) responseData.get('matchedCompany');

                    // 取得したデータを取引先レコードの項目に設定
                    Account updatedAccount = new Account(Id = acc.Id); // 更新対象のレコードIDを指定
                    if (matchedCompany.containsKey('corporateNumber')) {
                        updatedAccount.Corporate_Number__c = (String) matchedCompany.get('corporateNumber'); // 例：法人番号のカスタム項目
                    }
                    if (matchedCompany.containsKey('website')) {
                        updatedAccount.Website = (String) matchedCompany.get('website'); // 例：ウェブサイト
                    }
                    // その他のマッピング処理

                    accountsToUpdate.add(updatedAccount);
                }
            } else {
                // API連携が失敗した場合の処理（ログ出力など）
                System.debug('API連携に失敗しました。ステータスコード: ' + (res != null ? res.getStatusCode() : 'N/A') + ', ボディ: ' + (res != null ? res.getBody() : 'N/A'));
            }
        }

        // 更新する取引先レコードが存在する場合のみ更新
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            } catch (DmlException e) {
                // DML例外処理（ログ出力など）
                System.debug('取引先レコードの更新に失敗しました: ' + e.getMessage());
            }
        }
    }
}