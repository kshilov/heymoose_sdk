////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.heymoose.core.net
{
import flash.events.Event;

public class Responder implements IResponder
{
	public function Responder ( result:Function, fault:Function = null, log:Function = null )
	{
		super ();
		_resultHandler = result;
		_faultHandler = fault;
		_logHandler = log;
	}

	public function result ( data:Object ):void
	{
		if ( _resultHandler != null )
			_resultHandler ( data );
	}

	public function fault ( info:Object ):void
	{
		if ( _faultHandler != null )
			_faultHandler ( info );
	}

	public function log ( token:AsyncToken, event:Event ):void
	{
		if ( _logHandler != null )
			_logHandler ( token, event );
	}

	private var _resultHandler:Function;

	private var _faultHandler:Function;

	private var _logHandler:Function;
}


}