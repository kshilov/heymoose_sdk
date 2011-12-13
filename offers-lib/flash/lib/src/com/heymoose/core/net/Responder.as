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

public class Responder implements IResponder
{
	public function Responder ( result:Function, fault:Function )
	{
		super ();
		_resultHandler = result;
		_faultHandler = fault;
	}

	public function result ( data:Object ):void
	{
		_resultHandler ( data );
	}

	public function fault ( info:Object ):void
	{
		_faultHandler ( info );
	}

	private var _resultHandler:Function;

	private var _faultHandler:Function;
}


}