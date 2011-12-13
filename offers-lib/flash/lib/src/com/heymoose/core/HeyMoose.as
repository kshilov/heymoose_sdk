/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 11/23/11
 * Time: 11:29 PM
 */
package com.heymoose.core
{

import by.blooddy.crypto.MD5;

import com.heymoose.core.net.AsyncToken;


public class HeyMoose
{
	public static var _instance:HeyMoose;

	private var appId:int;
	private var secret:String;

	private var uid:String;

	private var platform:String;
	private var rewardCallback:Function;

	public function HeyMoose ()
	{

	}


	public static function get instance ():HeyMoose
	{
		if ( !HeyMoose._instance )
			HeyMoose._instance = new HeyMoose ();
		return HeyMoose._instance
	}


	public function init ( appId:int, secret:String, uid:String, platform:String, rewardCallback:Function = null ):void
	{
		this.appId = appId;
		this.secret = secret;
		this.uid = uid;
		this.platform = platform;
		this.rewardCallback = rewardCallback;
	}


	private var sex:String;
	private var year:String;


	public function setPerformer ( sex:String, year:String ):void
	{
		this.sex = sex;
		this.year = year;
	}


	public function introducePerformer ( sex:String = "", year:String = "" ):AsyncToken
	{
		var params:Object = new Object ();
		params['method'] = 'introducePerformer';
		sex == "" ? params['sex'] = this.sex : params['sex'] = sex;
		year == "" ? params['year'] = this.year : params['year'] = sex;
		return send ( params );
	}


	public function getOffers ( filter:String ):AsyncToken
	{
		var params:Object = new Object ();
		params['method'] = 'getOffers';
		params['filter'] = filter;
		return send ( params );
	}


	public function doOffer ( offerId:String ):String
	{
		var params:Object = new Object ();
		params['method'] = 'doOffer';
		params['offer_id'] = offerId;
		return getString ( params );
	}


	//////////////////////////////////////////
	// Atomic send
	//////////////////////////////////////////
	private function send ( params:Object ):AsyncToken
	{

		params['format'] = 'JSON';
		params['platform'] = platform;
		params['app_id'] = appId;
		params['uid'] = uid;
		params['nocache'] = Math.random ();
		params['sig'] = generateSig ( params );

		var token:AsyncToken = new AsyncToken ();
		return token.send ( "http://heymoose.com/rest_api/api", params );
	}


	private function getString ( params:Object ):String
	{
		params['format'] = 'JSON';
		params['platform'] = platform;
		params['app_id'] = appId;
		params['uid'] = uid;
		params['nocache'] = Math.random ();
		params['sig'] = generateSig ( params );

		var stringParams:Array = new Array ();
		for ( var param:String in params )
		{
			stringParams.push ( param + "=" + params[param] );
		}

		return "http://heymoose.com/rest_api/api" + "?" + stringParams.join ( "&" );
	}


	//////////////////////////////////////////
	// SIG Generator
	//////////////////////////////////////////
	private function generateSig ( params:Object ):String
	{
		return MD5.hash ( sortedParams ( params ) + this.secret );
	}


	private function sortedParams ( dct:Object ):String
	{
		var Keys:Array = this.extractKeysFrom ( dct );
		Keys.sort ();

		var res:String = "";
		for each ( var thisKey:* in Keys )
		{
			res += thisKey.toString ();
			res += "=";
			res += dct[thisKey].toString ();
		}
		return res;
	}


	private function extractKeysFrom ( source:Object ):Array
	{
		var output:Array = [];

		for ( var prop:* in source )
		{
			output.push ( prop );
		}
		return output;
	}
}
}