/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 10:41 AM
 */
package com.heymoose.offer
{
import com.heymoose.core.*;
import com.heymoose.core.event.ServiceEvent;
import com.heymoose.offer.event.BannerEvent;

import flash.display.MovieClip;

internal class OffersBase extends MovieClip
{
	protected var offers:Array;
	protected var services:HeyMoose;

	public function OffersBase ()
	{
		services = HeyMoose.instance;
		addEventListener ( ServiceEvent.REQUEST_FAULT, onRequestFailed );
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
			dispatchBannerError ();
			return false;
		}
		return true;
	}

	protected function onRequestFailed ( event:ServiceEvent ):void
	{
		if ( event.method != 'reportShow' )
		{
			dispatchBannerError ();
		}
	}

	protected function dispatchBannerError ( offer:Object = null ):void
	{
		if(hideOnError) visible = false;
		var bannerError:BannerEvent = new BannerEvent ( BannerEvent.BANNER_ERROR );
		bannerError.offer = offer;
		dispatchEvent ( bannerError );
	}

	private var _hideOnError:Boolean;
	public function get hideOnError ():Boolean
	{
		return _hideOnError;
	}

	public function set hideOnError ( value:Boolean ):void
	{
		_hideOnError = value;
	}
}
}
