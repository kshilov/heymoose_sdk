/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 3:25 PM
 */
package com.heymoose.core.net
{
import by.blooddy.crypto.serialization.JSON;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class AsyncToken extends EventDispatcher
{
	public var params:Object;
	public var url:String;
	public var target:Object;
	private var loader:URLLoader = new URLLoader ();

	public function AsyncToken ()
	{

	}

	public function send ( url:String, params:Object ):AsyncToken
	{
		this.url = url;
		this.params = params;

		var request:URLRequest = new URLRequest ( url );
		request.method = URLRequestMethod.GET;
		var variables:URLVariables = new URLVariables ();
		for ( var key:String in params )
		{
			variables[key] = params[key];
		}
		request.data = variables;
		loader.load ( request );
		loader.dataFormat = "text";
		loader.addEventListener ( Event.COMPLETE, loader_completeHandler );
		loader.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
		loader.addEventListener ( HTTPStatusEvent.HTTP_STATUS, loader_httpStatusHandler );
		loader.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );

		return this;
	}

	private function loader_completeHandler ( event:Event ):void
	{
		var result:Object = JSON.decode ( loader.data as String );
		setResult ( result );
		applyResult ( result );
		applyLog ( this, event );
	}

	private function loader_ioErrorHandler ( event:IOErrorEvent ):void
	{
		applyFault ( event );
		applyLog ( this, event );
	}

	private function loader_httpStatusHandler ( event:HTTPStatusEvent ):void
	{

	}

	private function loader_securityErrorHandler ( event:SecurityErrorEvent ):void
	{
		applyFault ( event );
		applyLog ( this, event );
	}

	//----------------------------------
	// responders
	//----------------------------------

	private var _responders:Array;

	public function get responders ():Array
	{
		return _responders;
	}

	//----------------------------------
	// result
	//----------------------------------

	private var _result:Object;


	public function get result ():Object
	{
		return _result;
	}

	//--------------------------------------------------------------------------
	//
	// Methods
	//
	//--------------------------------------------------------------------------


	public function addResponder ( responder:IResponder ):void
	{
		if ( _responders == null )
			_responders = [];

		_responders.push ( responder );
	}


	public function hasResponder ():Boolean
	{
		return (_responders != null && _responders.length > 0);
	}

	private function applyLog ( token:AsyncToken, event:Event ):void
	{
		if ( _responders != null )
		{
			for ( var i:uint = 0; i < _responders.length; i++ )
			{
				var responder:IResponder = _responders[i];
				if ( responder != null )
				{
					responder.log ( token, event );
				}
			}
		}
	}

	private function applyFault ( event:Object ):void
	{
		if ( _responders != null )
		{
			for ( var i:uint = 0; i < _responders.length; i++ )
			{
				var responder:IResponder = _responders[i];
				if ( responder != null )
				{
					responder.fault ( event );
				}
			}
		}
	}

	private function applyResult ( event:Object ):void
	{
		if ( _responders != null )
		{
			for ( var i:uint = 0; i < _responders.length; i++ )
			{
				var responder:IResponder = _responders[i];
				if ( responder != null )
				{
					responder.result ( event );
				}
			}
		}
	}

	private function setResult ( newResult:Object ):void
	{
		_result = newResult;
	}
}
}
