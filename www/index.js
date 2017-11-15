// JavaScript Document
CDV = ( typeof CDV == 'undefined' ? {} : CDV );
var cordova = window.cordova || window.Cordova;

CDV.iOSScanner = {

	getBC: function(params,cb) {
	  
	var settings = {
		
		PDF417Code		: false,
		QRCode			: false,
		EAN13Code		: false,
		UPCECode		: false,
		Code39Code		: false,
		Code39Mod43Code	: false,
		EAN8Code		: false,
		Code93Code		: false,
		Code128Code		: true,
		AztecCode		: false,
		DataMatrixCode  : true
		
	};
	
	for(var key in params) {
     
	    if(params.hasOwnProperty(key)) {
            settings[key] = params[key];
		}
	
	}
	
	var bcarray = [];
	
	for (var key in settings) {
	  if (settings.hasOwnProperty(key)) {
		  
		  if(settings[key]==true){
			  
			switch(key){
			
				case "UPCECode":
					bcarray.push('org.gs1.UPC-E');
				break;
				case "Code39Code":
					bcarray.push('org.iso.Code39');
				break;	
				case "Code39Mod43Code":
					bcarray.push('org.iso.Code39Mod4');
				break;	
				case "EAN13Code":
					bcarray.push('org.gs1.EAN-13');
				break;
				case "EAN8Code":
					bcarray.push('org.gs1.EAN-8');
				break;	
				case "Code93Code":
					bcarray.push('com.intermec.Code93');
				break;	
				case "Code128Code":
					bcarray.push('org.iso.Code128');
				break;	
				case "PDF417Code":
					bcarray.push('org.iso.PDF417');
				break;
				case "QRCode":
					bcarray.push('org.iso.QRCode');
				break;
				case "AztecCode":
					bcarray.push('org.iso.Aztec');
				break;
				case "DataMatrixCode":
					bcarray.push('org.iso.DataMatrix');
				break;
			}
		  
		  }
		
		}
	}
	
	cordova.exec(function callback(data) {
				console.log(JSON.stringify(data));
				if(typeof cb == 'function'){ cb.call(this,data); }
            
			},
			function errorHandler(err){
				
			},'iOSScanner','cordovaGetBC',bcarray);
  }
	
};
