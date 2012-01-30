/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 11/23/11
 * Time: 11:29 PM
 */
package com.heymoose.core
{

import by.blooddy.crypto.MD5;

import com.heymoose.core.event.ServiceEvent;
import com.heymoose.core.net.AsyncToken;
import com.heymoose.core.net.Responder;
import com.heymoose.utils.log.Log;
import com.heymoose.utils.log.LogEvent;
import com.heymoose.utils.log.LogItem;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.utils.Dictionary;
import flash.utils.getTimer;

public final class HeyMoose extends EventDispatcher
{
	private static var _instance:HeyMoose;

	private var appId:int;
	private var secret:String;

	private var uid:String;

	private var platform:String;
	private var rewardCallback:Function;

	private var showedOffers:Array;

	public var log:Log;
	private var tokenToLogItem:Dictionary = new Dictionary ();

	public var version:String = "1.1";

	public function HeyMoose ( s:SingletonEnforcer )
	{
		if ( s == null ) throw new Error ( "Singleton, please use HeyMoose.instance" );
	}


	public static function get instance ():HeyMoose
	{
		if ( !HeyMoose._instance )
			HeyMoose._instance = new HeyMoose ( new SingletonEnforcer () );
		_instance.showedOffers = new Array ();
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


	private var sex:String = 'NULL';
	private var year:String = 'NULL';
	private var city:String = 'NULL';


	public function setPerformer ( sex:String = 'NULL', year:String = 'NULL', city:String = 'NULL' ):void
	{
		this.sex = sex;
		this.year = year;
		this.city = city;
	}


	public function introducePerformer ( sex:String = 'NULL', year:String = 'NULL', city:String = 'NULL' ):AsyncToken
	{
		var params:Object = new Object ();
		params['method'] = 'introducePerformer';
		sex == 'NULL' ? params['sex'] = this.sex : params['sex'] = sex;
		year == 'NULL' ? params['year'] = this.year : params['year'] = year;
		city == 'NULL' ? params['city'] = this.city : params['city'] = city;
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

	public function doOfferLog ( offerId:String ):AsyncToken
	{
		var params:Object = new Object ();
		params['method'] = 'doOffer';
		params['offer_id'] = offerId;
		return send ( params );
	}

	public function reportShow ( offerId:String ):AsyncToken
	{
		if ( showedOffers.indexOf ( offerId ) > -1 )
			return null;

		showedOffers.push ( offerId );

		var params:Object = new Object ();
		params['method'] = 'reportShow';
		params['offer_id'] = offerId;
		return send ( params );
	}


	//////////////////////////////////////////
	// Atomic send
	//////////////////////////////////////////
	private function send ( params:Object ):AsyncToken
	{
		if(platform == null)
		{
			trace("ERROR: Please init HeyMoose first (HeyMoose.instance.init)")
			return null;
		}
		var token:AsyncToken = new AsyncToken ();

		for ( var key:String in params )
		{
			if ( params[key] == null || params[key] == 'NULL' )
			{
				delete params[key];
			}
		}

		params['format'] = 'JSON';
		params['platform'] = platform;
		params['app_id'] = appId;
		params['uid'] = uid;
		params['nocache'] = Math.random ();
		params['sig'] = generateSig ( params );

		// LOG
		if ( log )
		{
			token.addResponder ( new Responder ( null, null, logToken ) );
			var logItem:LogItem = new LogItem ( token );
			logItem.startTime = getTimer ();
			logItem.request = generateString ( params );
			logItem.method = params['method'];
			log.sourceArray.unshift ( logItem );
			tokenToLogItem[token] = logItem;
			log.dispatchEvent ( new LogEvent () );
		}

		token.addResponder ( new Responder ( null, null, requestHandler ) );

		dispatchEvent ( new ServiceEvent ( ServiceEvent.REQUEST_SENT, params['method'], generateString ( params ) ) );

		return token.send ( "http://heymoose.com/rest_api/api", params );
	}

	private function requestHandler ( token:AsyncToken, event:Event ):void
	{
		if ( event.type == Event.COMPLETE )
		{
			var completeEvent:Event = new ServiceEvent ( ServiceEvent.REQUEST_COMPLETED, token.params['method'], generateString ( token.params ) );
			dispatchEvent ( completeEvent );
			token.target.dispatchEvent ( completeEvent );
		}
		else
		{
			var faultEvent:Event = new ServiceEvent ( ServiceEvent.REQUEST_FAULT, token.params['method'], generateString ( token.params ) );
			dispatchEvent ( faultEvent );
			token.target.dispatchEvent ( faultEvent );
		}
		token.target = null;
	}

	private function logToken ( token:AsyncToken, event:Event ):void
	{
		var logItem:LogItem = LogItem ( tokenToLogItem[token] );
		switch ( event.type )
		{
			case Event.COMPLETE:
				logItem.result = event.target.data;
				break;
			case IOErrorEvent.IO_ERROR:
				logItem.result = IOErrorEvent ( event ).text;
				logItem.fault = true;
				break;
		}
		logItem.endTime = getTimer ();
		log.dispatchEvent ( new LogEvent () );
		delete tokenToLogItem[token];
	}


	private function getString ( params:Object ):String
	{
		for ( var key:String in params )
		{
			if ( params[key] == null || params[key] == 'NULL' )
			{
				delete params[key];
			}
		}

		params['format'] = 'JSON';
		params['platform'] = platform;
		params['app_id'] = appId;
		params['uid'] = uid;
		params['nocache'] = Math.random ();
		params['sig'] = generateSig ( params );

		return generateString ( params )
	}

	private function generateString ( params:Object ):String
	{
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
class SingletonEnforcer
{
}