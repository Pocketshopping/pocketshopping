const functions = require('firebase-functions');
const admin = require('firebase-admin');
const serviceAccount = require('./pocketshopping.json');
//initialize admin SDK using serciceAcountKey
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});

exports.FetchNearByMerchants = functions.https.onCall((data, context) => {
  return data['points'];
});


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

exports.test = functions.https.onRequest((req, res) => {
  getCategories(req.query.mID).then((doc)=>{
    res.send(doc);
  })

});

