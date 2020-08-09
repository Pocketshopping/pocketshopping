const functions = require('firebase-functions');
const admin = require('firebase-admin');
const serviceAccount = require('./pocketshopping.json');
const fetch = require('node-fetch');
const apriori = require('node-apriori');
//initialize admin SDK using serciceAcountKey
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});
const runtimeOpts = {
  timeoutSeconds: 300,
  memory: '512MB'
}

const CategoryRuntimeOpts = {
  timeoutSeconds: 120,
  memory: '512MB'
}

/* exports.FetchNearByMerchants = functions.https.onCall((data, context) => {
  return data['points'];
}); */

 exports.scheduledFunction = functions.pubsub.schedule('every 2 minutes')
 .timeZone('Africa/Bangui') 
 .onRun(async(context) => {
  await fetchAndUpdate();
  return null;
}); 


 exports.FetchMerchantsProductCategory = functions.runWith(CategoryRuntimeOpts).https.onCall((data, context) => {
     var merchant = data['mID'];
     return getCategories(merchant).then((doc)=>{
       return doc;
     });
});

exports.staffOneDayGeneralStat = functions.runWith(CategoryRuntimeOpts).https.onCall(async(data, context) => {
  const merchant = data['mID'];
  const staff = data['sID'];
  const start = data['start'];
  const end = data['end'];
     return await staffOneDayStatistic(new Date(start),new Date(end),merchant,staff);
});

exports.merchantOneDayGeneralStat = functions.runWith(CategoryRuntimeOpts).https.onCall(async(data, context) => {
  const merchant = data['mID'];
  const start = data['start'];
  const end = data['end'];
     return await merchantOneDayStatistic(new Date(start),new Date(end),merchant);
});

 exports.merchantThirtyDaysGeneralStat = functions.https.onCall(async(data, context) => {
  const merchant = data['mID'];
  const thirty = data['thirty'];
     return await merchantStatistic(new Date(thirty),merchant);
});

/* exports.addMessage = functions.https.onRequest(async (req, res) => {
  const original = req.query.text;
  const nDay = req.query.day;
  const merchant = req.query.merchant;
  const staff = req.query.staff;
  //res.json({result: await merchantStatistic(new Date(original),merchant)});
  //res.json({result: await merchantOneDayStatistic(new Date(original),new Date(nDay),merchant)});
  res.json({result: await staffOneDayStatistic(new Date(original),new Date(nDay),merchant,staff)});
});
 */
async function merchantOneDayStatistic(day,nextDay,merchant){
  let transactions = await admin.firestore()
              .collection('transactions')
              .orderBy('insertedAt','desc')
              .where('mid','==',merchant)
              .where('insertedAt','>',day)
              .where('insertedAt','<',nextDay)
              .get();
//total transaction in the give date
let count = transactions.docs.length;
//total amount made
let total = 0;
//start of most bought item in the last 30 days
let items=[];
let most = new Map();
transactions.docs.forEach((doc) => {
items = items.concat(doc.data()['items']);
total = total + doc.data()['amount'];
});
items.forEach(function(e) {
if(most[e] === undefined) {
  most[e] = 0
}
most[e] += 1
});
let entries = Object.entries(most);
let sorted = entries.sort((a, b) => a[1] - b[1]);
let sliced=[];
if(sorted.length > 5)
sliced = sorted.reverse().slice(0,5);
else
sliced = sorted.reverse();
//end of most bought items
return {'transactionCount':count,'mostFiveItems':sliced,'total':total,};

}

async function staffOneDayStatistic(day,nextDay,merchant,staff){
  let transactions = await admin.firestore()
              .collection('transactions')
              .orderBy('insertedAt','desc')
              .where('mid','==',merchant)
              .where('sid','==',staff)
              .where('insertedAt','>',day)
              .where('insertedAt','<',nextDay)
              .get();
//total transaction in the give date
let count = transactions.docs.length;
//total amount made
let total = 0;
//start of most bought item in the last 30 days
let items=[];
let most = new Map();
transactions.docs.forEach((doc) => {
items = items.concat(doc.data()['items']);
total = total + doc.data()['amount'];
});
items.forEach(function(e) {
if(most[e] === undefined) {
  most[e] = 0
}
most[e] += 1
});
let entries = Object.entries(most);
let sorted = entries.sort((a, b) => a[1] - b[1]);
let sliced=[];
if(sorted.length > 5)
sliced = sorted.reverse().slice(0,5);
else
sliced = sorted.reverse();
//end of most bought items
return {'transactionCount':count,'mostFiveItems':sliced,'total':total,};

}



async function merchantStatistic(range,merchant){
    let transactions = await admin.firestore()
                .collection('transactions')
                .orderBy('insertedAt','desc')
                .where('mid','==',merchant)
                .where('insertedAt','>',range)
                .get();
//total transaction in the last 30 days
let count = transactions.docs.length;
//start of week day transaction count
let weekDays = [0,0,0,0,0,0,0];
//start of date closing amount
let daysTotal = new Map();
//start of most bought item in the last 30 days
let items=[];
let allItems = [];
let most = new Map();
transactions.docs.forEach((doc) => {
  items = items.concat(doc.data()['items']);
  weekDays[(doc.data()['day']-1)] ++;
  let key = `${doc.data()['insertedAt'].toDate().getDate()}-${(doc.data()['insertedAt'].toDate().getMonth())+1}-${doc.data()['insertedAt'].toDate().getFullYear()}`;
  if( daysTotal[key] === undefined ) {
    daysTotal[key] =  doc.data()['amount'];
}
else{
  daysTotal[key] = daysTotal[key] + doc.data()['amount'];
}
if(doc.data()['items'].length > 1)
allItems.push(doc.data()['items'].sort());
});
items.forEach(function(e) {
  if(most[e] === undefined) {
    most[e] = 0
  }
  most[e] += 1
});
let entries = Object.entries(most);
let sorted = entries.sort((a, b) => a[1] - b[1]);
let sliced=[];
if(sorted.length > 5)
sliced = sorted.reverse().slice(0,5);
else
sliced = sorted.reverse();
//end of most bought items
//end of week daya transaction count

//let pairs = fi(allItems,0.4,false);
let ap=  new apriori.Apriori(.1);
let result = allItems.length>10000?ap.exec(allItems.slice(0,10001)):ap.exec(allItems);
let pairs = (await result).itemsets;
let filteredItems = pairs.filter(function(item){return item.items.length>1;});
let filteredSortedItems = filteredItems.sort((a, b) => a['support'] - b['support']);
let finalPairs=[];
if(filteredSortedItems.length > 20)
finalPairs = filteredSortedItems.reverse().slice(0,21);
else
finalPairs = filteredSortedItems.reverse();


return {'transactionCount':count,'mostFiveItems':sliced,'weekDaysCount':weekDays,'growthChart':daysTotal,'pairs':finalPairs};
}


async function finalizePending(collectionID,key){

  const body = {"collectionID": collectionID, "status": false, };
        await fetch('http://middleware.pocketshopping.com.ng/api/wallets/pay/finalize/', {
        method: 'post',
        body:    JSON.stringify(body),
        headers: { 'Content-Type': 'application/json', 'ApiKey':key},
    })
}

 async function fetchAndUpdate(){
  var documents = await admin.firestore()
    .collection('orders')
    .where('isAssigned','==',false)
    .where('status','==',0)
    .where('etc','<', new Date())
    .limit(500)
    .get();

    var key = await admin.firestore()
    .collection('server')
    .doc('wallet')
    .get();

    let batch = admin.firestore().batch();
    var customers =[];
    const payload = {
      notification: {
          title: "Delivery",
          body: "Your Delivery has been cancelled( Logistic problem)",
          sound: "default",
          icon : "app_icon",
      },
  
      data: {
          
          'payload':JSON.stringify( {
            "NotificationType": "CloudDeliveryCancelledResponse",
            'message':'Your Delivery has been cancelled( Logistic problem)',
            'title':'Delivery',
          }),
      }
    };


    if(documents.docs.length>0){
    documents.docs.forEach((doc) => {
      const docRef = admin.firestore().collection('orders').doc(doc.id);
      batch.update(docRef, {'isAssigned':true,'potentials':[],'status':1,'receipt.pRef':'Rider Currently unavailable.','receipt.psStatus':'fail'});
      customers.push(doc.data()['customerDevice']);
      finalizePending(doc.data()['receipt']['collectionID'],key.data()['key']).then(res => null);
  })
  await batch.commit();
  if(customers.length>0)
  admin.messaging().sendToDevice(customers, payload);
}

}
 
async function getCategories(merchant) {
  var category=[];
  var tmp = new Object();
  var sortable = [];
  
    var doc = await admin.firestore()
    .collection('products')
    .where('productMerchant','==',admin.firestore().collection('merchants').doc(merchant))
    .where('productAvailability','==',1)
    .where('productStatus','==',1)
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
  var distance =data['distance']; //current distance between user and merchant
  var type =data['type']; //type of order
  var ttc = data['ttc']; // total time of customer left
  var server = data['server']; // number of servers in a store
  var top = data['top']; // time of operation
  var eta=0.0; // expected time of delivery
  if(type == 'Delivery')
    eta = (distance/8.33333)+960;
  else if(type == 'Pickup') 
    eta = top*1.0;
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
  if(distance < 1000)
    cut = 300;
  else
    cut = Math.round((Math.abs(Math.round(distance/1000) - 3)*y1+c));

    return cut;
});


exports.ErrandDeliveryCut = functions.https.onCall((data, context) => {
  var distance=data['distance'];
  var y1 = 50;
  var bikeBase = 300;
  var carBase = 600;
  var vanBase = 5000;
  var bikeCut=0;
  var carCut=0;
  var vanCut=0; 
  var cut = [];

  if(distance < 1000)
  {
    bikeCut = bikeBase;
    cut.push(bikeCut);
    carCut = carBase;
    cut.push(carCut);
    vanCut = vanBase; 
    cut.push(vanCut); 
  }
  else
    {
      bikeCut = Math.round((Math.abs(Math.round(distance/1000))*y1+bikeBase));
      cut.push(bikeCut);
      carCut = Math.round((Math.abs(Math.round(distance/1000))*y1+carBase));
      cut.push(carCut);
      vanCut = Math.round((Math.abs(Math.round(distance/1000))*y1+vanBase));
      cut.push(vanCut);
    }

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