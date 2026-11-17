package dev.onedash.app

import android.view.WindowManager
import androidx.core.content.ContextCompat
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val secureChannelName = "dev.onedash.app/secure_screen"
    private val passkeyChannelName = "dev.onedash.app/passkey"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, secureChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, passkeyChannelName)
            .setMethodCallHandler { call, result -> handlePasskeyCall(call, result) }
    }

    private fun handlePasskeyCall(call: MethodCall, result: MethodChannel.Result) {
        val requestJson = call.argument<String>("requestJson")
        if (requestJson.isNullOrBlank()) {
            result.error("invalid_request", "Missing WebAuthn request", null)
            return
        }
        val manager = CredentialManager.create(this)
        val executor = ContextCompat.getMainExecutor(this)
        when (call.method) {
            "create" -> {
                val request = CreatePublicKeyCredentialRequest(
                    requestJson = requestJson,
                    clientDataHash = null,
                    preferImmediatelyAvailableCredentials = false,
                    origin = null,
                    preferDefaultProvider = null,
                    isAutoSelectAllowed = false,
                )
                manager.createCredentialAsync(
                    context = this,
                    request = request,
                    cancellationSignal = null,
                    executor = executor,
                    callback = object : CredentialManagerCallback<
                        CreateCredentialResponse,
                        CreateCredentialException
                        > {
                        override fun onResult(response: CreateCredentialResponse) {
                            val json = (response as? CreatePublicKeyCredentialResponse)
                                ?.registrationResponseJson
                            if (json.isNullOrBlank()) {
                                result.error(
                                    "passkey_create_failed",
                                    "Credential provider returned no registration response",
                                    null,
                                )
                            } else {
                                result.success(json)
                            }
                        }

                        override fun onError(error: CreateCredentialException) {
                            result.error(
                                if (error is CreateCredentialCancellationException) {
                                    "passkey_cancelled"
                                } else {
                                    "passkey_create_failed"
                                },
                                error.message ?: "Passkey registration failed",
                                null,
                            )
                        }
                    },
                )
            }
            "get" -> {
                val option = GetPublicKeyCredentialOption(requestJson = requestJson)
                val request = GetCredentialRequest(listOf(option))
                manager.getCredentialAsync(
                    context = this,
                    request = request,
                    cancellationSignal = null,
                    executor = executor,
                    callback = object : CredentialManagerCallback<
                        GetCredentialResponse,
                        GetCredentialException
                        > {
                        override fun onResult(response: GetCredentialResponse) {
                            val json = (response.credential as? PublicKeyCredential)
                                ?.authenticationResponseJson
                            if (json.isNullOrBlank()) {
                                result.error(
                                    "passkey_get_failed",
                                    "Credential provider returned no authentication response",
                                    null,
                                )
                            } else {
                                result.success(json)
                            }
                        }

                        override fun onError(error: GetCredentialException) {
                            result.error(
                                if (error is GetCredentialCancellationException) {
                                    "passkey_cancelled"
                                } else {
                                    "passkey_get_failed"
                                },
                                error.message ?: "Passkey sign-in failed",
                                null,
                            )
                        }
                    },
                )
            }
            else -> result.notImplemented()
        }
    }
}
