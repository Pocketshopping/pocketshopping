package fleepage.pocketshopping

import android.os.Bundle
import android.os.PersistableBundle
import co.paystack.android.PaystackSdk
import io.flutter.embedding.android.FlutterActivity
import androidx.core.content.ContextCompat.getSystemService
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import co.paystack.android.model.Card
import androidx.core.content.ContextCompat.getSystemService
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import co.paystack.android.Paystack
import co.paystack.android.model.Charge
import androidx.core.content.ContextCompat.getSystemService
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import co.paystack.android.Transaction




class MainActivity: FlutterActivity() {
    private val CHANNEL = "fleepage.pocketshopping"


    fun  DisplayHello():String{
        return "hello dude"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        PaystackSdk.initialize(getApplicationContext())
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->

                    if (call.method=="CardVerify"){



                    }
                    else if (call.method =="CardPay"){
                        //PaystackSdk.initialize(getApplicationContext())
                        val charge = Charge()

                        charge.card = paycard()
                        charge.email="manuelemeka@gmail.com"
                        charge.amount=400//sets the card to charge

                        PaystackSdk.chargeCard(this@MainActivity, charge, object : Paystack.TransactionCallback {
                            override fun onSuccess(transaction: Transaction) {
                                // This is called only after transaction is deemed successful.
                                // Retrieve the transaction, and send its reference to your server
                                // for verification.
                                //result.success(transaction.reference)
                                //charge.reference = transaction.reference
                                result.success(transaction.reference)
                            }

                            override fun beforeValidate(transaction: Transaction) {
                                // This is called only before requesting OTP.
                                // Save reference so you may send to server. If
                                // error occurs with OTP, you should still verify on server.
                                //result.success(transaction.reference)
                                print("fail")
                            }

                            override fun onError(error: Throwable, transaction: Transaction) {
                                //handle error here
                                result.success("ERROR")
                            }

                        })
                    }
                    else{
                        result.success("fuck kotlin")
                    }
                }


                    super.configureFlutterEngine(flutterEngine)
                }

    fun paycard():Card{
        val cardNumber = "5060666666666666666"
        val expiryMonth = 3 //any month in the future
        val expiryYear = 22 // any year in the future. '2018' would work also!
        val cvv = "123"  // cvv of the test card

        val card = Card(cardNumber, expiryMonth, expiryYear, cvv)
        return card
    }


    fun performCharge() {
        //create a Charge object

    }
            }
