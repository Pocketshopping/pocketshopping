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
import android.util.Log
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

                        var month:Int? = call.argument<Int>("month")
                        var cnumber:String = call.argument<String>("card").toString()
                        var year:Int? = call.argument<Int>("year")
                        var cvv:String? = call.argument<String>("cvv")

                        var charge = Charge()
                        charge.card = Card(cnumber, month, year, cvv)
                        //Log.e("cnumber",charge.card.toString())
                        charge.email=call.argument<String>("email").toString()//"manuelemeka@gmail.com"
                        charge.amount=call.argument<Int>("amount")!!.toInt()*100//400//sets the card to charge
                        PaystackSdk.chargeCard(this@MainActivity, charge, object : Paystack.TransactionCallback {
                            override fun onSuccess(transaction: Transaction) {
                                // This is called only after transaction is deemed successful.
                                // Retrieve the transaction, and send its reference to your server
                                // for verification.
                                //result.success(transaction.reference)
                                //charge.reference = transaction.reference
                                val response:MutableMap<String,String> = mutableMapOf()
                                response["error"]=""
                                response["reference"]=transaction.reference
                                result.success(response)
                            }

                            override fun beforeValidate(transaction: Transaction) {
                                // This is called only before requesting OTP.
                                // Save reference so you may send to server. If
                                // error occurs with OTP, you should still verify on server.
                                //result.success(transaction.reference)
                                //print("fail")
                            }

                            override fun onError(error: Throwable, transaction: Transaction) {
                                //handle error here
                                val response:MutableMap<String,String> = mutableMapOf()
                                response["error"]=error.message.toString()
                                response["reference"]=""
                                result.success(response)
                            }

                        })
                    }
                    else{
                        result.success("PayStack")
                    }
                }


                    super.configureFlutterEngine(flutterEngine)
                }

    fun paycard(cNumber: String, eMonth:Int?, eYear:Int?, cvv:String? ):Card{
        var cardNumber = cNumber//"5060666666666666666"
        var expiryMonth =3// eMonth //expiryMonth
        var expiryYear = 22//eYear //expiryYear
        var cvv = "123"//cvv//"$cvv"//"123"  // cvv of the test card
        return Card(cardNumber, expiryMonth, expiryYear, cvv)
    }


    fun performCharge() {
        //create a Charge object

    }
            }
