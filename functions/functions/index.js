const functions = require('firebase-functions');
const admin = require('firebase-admin');
const serviceAccount = require('./pocketshopping.json');
//initialize admin SDK using serciceAcountKey
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});
const runtimeOpts = {
  timeoutSeconds: 300,
  memory: '1GB'
}

const CategoryruntimeOpts = {
  timeoutSeconds: 120,
  memory: '512MB'
}

/* exports.FetchNearByMerchants = functions.https.onCall((data, context) => {
  return data['points'];
}); */



 exports.FetchMerchantsProductCategory = functions.https.onCall((data, context) => {
     var merchant = data['mID'];
     return getCategories(merchant).then((doc)=>{
       return doc;
     });
}); 

async function getCategories(merchant) {
  var category=[];
  var tmp = new Object();
  var sortable = [];
  
    var doc = await admin.firestore()
    .collection('products')
    .where('productMerchant','==',admin.firestore()
    .collection('merchants').doc(merchant))
    .get();

    doc.docs.forEach((result)=>{
      var pc=result.data()['productCategory'];
      if(tmp[pc] != null){
        tmp[pc]=tmp[pc]+1;
      }
      else{
        tmp[pc] =1;
      }
   });

    for (var item in tmp) {
      sortable.push([item, tmp[item]]);
   }
   
   sortable.sort(function(a, b) {
      return a[1] - b[1];
   });
   sortable.reverse();
   
   sortable.forEach((slice)=>{
    category.push(slice[0]);
   });
    

    return category;
}

/* exports.test = functions.https.onRequest((req, res) => {
  getCategories(req.query.mID).then((doc)=>{
    res.send(doc);
  })

}); */

exports.PickupETA = functions.https.onCall((data, context) => {
  var eta =360;

    return eta;
});

exports.ETA = functions.https.onCall((data, context) => {
  var distance =data['distance'];
  var type =data['type']; 
  var ttc = data['ttc'];
  var server = data['server'];
  var top = data['top'];
  var eta=0.0;
  if(type == 'Delivery')
    eta = (distance/8.33333)+960;
  else if(type == 'Pickup') 
    eta = top;
  else
    eta = (ttc/server)+top;   

    return eta;
});

exports.DeliveryCut = functions.https.onCall((data, context) => {
  var distance=data['distance'];
  var y1 = 50;
  var y2 = 100;
  var c = 300;
  var cut=0;
  if(distance < 3000)
    cut = 300;
  else if(distance<500)
    cut = Math.round((((distance/1000) - 3)*y1+c));
  else
    cut = Math.round((((distance/1000) - 3)*y2+c));

    return cut;
});


exports.NewOrder =  functions.https.onCall((data, context) => {
  var order =data['order']; 
  const lat = data["lat"];
  const long = data["long"];
  var isDone = false;
  var guess='';
  
  //while(!isDone){
    guess = randomString(8, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
     var doc = null;
     /* admin.firestore()
    .collection('orders')
    .where('orderID','==',guess)
    .get().then((result)=>{
      if(result != null){
        if(result.empty)
      isDone = true; 
      else
      isDone = false; 
      }
      else
        isDone = true;
      
    }); */
  //}

      /* order['orderID']=guess;
      if(lat != null){
        order['orderMode']['coordinate']=admin.firestore.GeoPoint(lat,long);
      }
      order['orderCreatedAt']=admin.firestore.Timestamp.now;
      await admin.firestore().collection('orders').add(order); */

      return guess;
 
});




function randomString(length, chars) {
  var result = '';
  for (var i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];
  return result;
}