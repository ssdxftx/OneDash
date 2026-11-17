# OneDash Passkey（Android）

OneDash 通过 Android Credential Manager 调用系统通行密钥提供方，完成 1Panel 的 Passkey 登录与注册。

## 流程

1. App 调用 `POST /api/v2/core/auth/passkey/begin`，拿到 `sessionId` 与 WebAuthn `publicKey`。
2. 原生层把 `publicKey` 原样交给 `androidx.credentials`，由系统弹出通行密钥选择器或注册器。
3. App 把返回的 WebAuthn JSON 提交到 `POST /api/v2/core/auth/passkey/finish`，响应头带 `Passkey-Session`。
4. 面板校验通过后下发 `psession`，App 保存会话。

注册流程对应 `/register/begin` 与 `/register/finish`，注册请求需要面板会话。

## 使用条件

1. 面板已设置 `BindDomain`，例如 `panel.example.com`。
2. App 的服务器地址必须使用 `https://panel.example.com`，且主机名与 `BindDomain` 完全一致。使用 IP、其他域名或 HTTP 时，Passkey 按钮不会显示。
3. 面板把 `/.well-known/assetlinks.json` 暴露在同一域名下，且返回 `200`、`Content-Type: application/json`、无跳转。
4. 面板证书可被 Android 信任。
5. 面板修改 `BindDomain` 会清空已注册 Passkey，这是 1Panel 的服务端行为。

## assetlinks.json

把下面内容保存为 `assetlinks.json`，由面板域名的反向代理提供：

```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "dev.onedash.app",
      "sha256_cert_fingerprints": [
        "92:98:E4:94:77:E6:61:E6:D9:3A:5A:6C:91:2D:FD:0B:BF:B3:E3:82:7B:8D:A5:AD:D6:1D:C5:BB:B1:1E:27:E1"
      ]
    }
  }
]
```

上面的指纹是当前测试 APK 的 Android Debug 证书。换成正式签名后，需要把正式证书的 SHA-256 指纹加入数组；可以同时保留多个指纹。

获取指纹：

```bash
apksigner verify --print-certs OneDash-1.0.0-arm64-v8a-release.apk
```

## 反向代理示例

如果面板由 Nginx 暴露：

```nginx
location = /.well-known/assetlinks.json {
    default_type application/json;
    add_header Cache-Control "no-store";
    alias /etc/1panel/assetlinks.json;
}
```

如果使用 1Panel 的 OpenResty 站点配置，把同样的 location 放进面板域名的 server 块。配置后检查：

```bash
curl -i https://panel.example.com/.well-known/assetlinks.json
```

## 验证

1. 在面板网页注册一个 Passkey，确认面板本身可用 HTTPS 和绑定域名完成 WebAuthn。
2. 安装 OneDash arm64 APK，服务器地址填 `https://panel.example.com`。
3. 面板设置 → 登录，出现“使用通行密钥登录”；选择已注册的 Passkey。
4. 面板设置 → 通行密钥 → 在此设备注册，输入名称后完成系统验证。

## 限制

- iOS 需要 `apple-app-site-association`，当前实现只覆盖 Android；iOS 使用浏览器注册入口。
- 自建面板如果没有配置 `assetlinks.json`，系统会拒绝创建或使用该域名的 Passkey。这是 Android 的应用关联要求，客户端无法绕过。
- 该实现不申请 `CREDENTIAL_MANAGER_SET_ORIGIN` 权限，不代理其他应用或浏览器发起请求。
