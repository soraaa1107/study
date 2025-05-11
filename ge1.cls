public with sharing class CompanyDataApiClient {

    // APIのエンドポイント（カスタム設定などから取得することを推奨）
    private static final String API_ENDPOINT = 'YOUR_API_ENDPOINT_HERE';
    // APIの認証トークンなど（カスタム設定などから取得することを推奨）
    private static final String API_TOKEN = 'YOUR_API_TOKEN_HERE';

    public static HttpResponse fetchCompanyData(String companyName, String address, String phone) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(API_ENDPOINT);
        req.setMethod('POST'); // APIのメソッドに合わせて変更
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + API_TOKEN); // APIの認証方式に合わせて変更

        // APIに送信するリクエストボディの作成
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'companyName' => companyName,
            'address' => address,
            'phone' => phone
            // その他の検索キーとなる情報を必要に応じて追加
        };
        String requestBody = JSON.serialize(requestBodyMap);
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = null;

        try {
            res = http.send(req);
        } catch (Exception e) {
            // 例外処理（ログ出力など）
            System.debug('APIリクエスト中にエラーが発生しました: ' + e.getMessage());
            // エラー発生時はnullまたはエラーを示すHttpResponseを返すことを検討
            return null;
        }
        return res;
    }
}