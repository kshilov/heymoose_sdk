/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 10:41 AM
 */
package com.heymoose.core
{
import by.blooddy.crypto.serialization.JSON;

import flash.display.MovieClip;

public class OffersBase extends MovieClip
{
	protected var offers:Array;
	private var _services:HeyMoose;

	public function OffersBase ( services:HeyMoose )
	{
		this._services = services;
	}

	protected function getOffersResult ( result:String ):void
	{
		var resultObject:Object = JSON.decode ( result );
		offers = resultObject.result;
	}

	protected function fault ( fault:Object ):void
	{
		trace("REQUEST FAULT")
	}

	public function get services ():HeyMoose
	{
		if(_services == null) throw new Error("Please initialize offer with services or set services in constructor");
		return _services;
	}

	public function set services ( value:HeyMoose ):void
	{
		_services = value;
	}
}
}
