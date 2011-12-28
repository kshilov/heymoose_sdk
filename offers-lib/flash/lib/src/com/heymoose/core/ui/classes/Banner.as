/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/7/11
 * Time: 8:18 PM
 */
package com.heymoose.core.ui.classes
{
import com.heymoose.core.HeyMoose;
import com.heymoose.core.OffersBase;
import com.heymoose.offer.event.BannerEvent;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class Banner extends OffersBase
{
	protected var bannerWidth:int;
	protected var bannerHeight:int;
	protected var bannerSizeId:String;


	protected var currentOfferIndex:int = 0;

	public function Banner ( size:String = "0x0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
	{
		super ( services );
		bannerWidth = int ( size.split ( "x" )[0] );
		bannerHeight = int ( size.split ( "x" )[1] );
		bannerSizeId = size;

		graphics.beginFill ( backgroundColor, backgroundAlpha );
		graphics.lineStyle ( 1, 0, 0.5 );
		graphics.drawRect ( 0, 0, bannerWidth, bannerHeight );
		graphics.endFill ();

		addEventListener ( MouseEvent.CLICK, onMouseClick );
	}

	private function onMouseClick ( event:MouseEvent ):void
	{
		dispatchEvent ( new BannerEvent ( BannerEvent.CLICK, offers[currentOfferIndex], true ) );
		navigateToURL ( new URLRequest ( services.doOffer ( offers[currentOfferIndex].id ) ) );
	}


	protected function nextOffer ():void
	{
		++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;

		playOffer ();
	}

	protected function playOffer ():void
	{
		services.reportShow(offers[currentOfferIndex]);
		dispatchEvent ( new BannerEvent ( BannerEvent.SHOW, offers[currentOfferIndex], true ) );
	}
}
}
