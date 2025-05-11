trigger EnrichAccountDataTrigger on Account (after insert, after update) {
    List<Account> accountsToProcess = new List<Account>();

    // insert時の処理
    if (Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            accountsToProcess.add(acc);
        }
    }

    // update時の処理（変更があった場合のみ処理を実行するように考慮）
    if (Trigger.isUpdate) {
        for (Account newAcc : Trigger.new) {
            Account oldAcc = Trigger.oldMap.get(newAcc.Id);
            // 企業名、住所、電話番号のいずれかが変更された場合に処理を実行
            if (newAcc.Name != oldAcc.Name ||
                (newAcc.BillingAddress != null && oldAcc.BillingAddress != null &&
                 (newAcc.BillingAddress.street != oldAcc.BillingAddress.street ||
                  newAcc.BillingAddress.city != oldAcc.BillingAddress.city ||
                  newAcc.BillingAddress.state != oldAcc.BillingAddress.state ||
                  newAcc.BillingAddress.country != oldAcc.BillingAddress.country)) ||
                newAcc.Phone != oldAcc.Phone) {
                accountsToProcess.add(newAcc);
            }
        }
    }

    // データ格納処理クラスを呼び出す
    if (!accountsToProcess.isEmpty()) {
        AccountDataHandler.enrichAccountData(accountsToProcess);
    }
}