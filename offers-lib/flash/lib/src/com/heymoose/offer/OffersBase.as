/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 10:41 AM
 */
package com.heymoose.offer
{
import com.heymoose.core.*;
import com.heymoose.offer.event.BannerEvent;

import flash.display.MovieClip;

internal class OffersBase extends MovieClip
{
	protected var offers:Array;
	private var _services:HeyMoose;

	public function OffersBase ( services:HeyMoose )
	{
		this._services = services;
	}

	protected function getOffersResult ( result:Object ):void
	{

	}

	protected function setOffersResult ( result:Object ):Boolean
	{
		offers = result.result;

		if ( !offers || offers.length == 0 )
		{
			var offersListEmptyEvent:BannerEvent = new BannerEvent ( BannerEvent.OFFERS_LIST_EMPTY );
			dispatchEvent ( offersListEmptyEvent );
			return false;
		}
		return true;
	}

	public function get services ():HeyMoose
	{
		if ( _services == null ) throw new Error ( "Please initialize offer with services or set services in constructor" );
		return _services;
	}

	public function set services ( value:HeyMoose ):void
	{
		_services = value;
	}
}
}
