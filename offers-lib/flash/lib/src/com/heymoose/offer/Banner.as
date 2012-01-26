/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/7/11
 * Time: 8:18 PM
 */
package com.heymoose.offer
{
import com.heymoose.core.HeyMoose;
import com.heymoose.core.net.AsyncToken;
import com.heymoose.offer.event.BannerEvent;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

internal class Banner extends OffersBase
{
	protected var bannerWidth:int;
	protected var bannerHeight:int;
	protected var bannerSizeId:String;


	protected var currentOfferIndex:int = 0;

	public function Banner ( size:String = "0x0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
	{
		super ( services );
		var sizeParts:Array = size.split ( "x" );
		if ( sizeParts.length != 2 ) throw ( new Error ( 'Invalid banner size' ) );
		bannerWidth = int ( sizeParts[0] );
		bannerHeight = int ( sizeParts[1] );
		bannerSizeId = size;

		graphics.beginFill ( backgroundColor, backgroundAlpha );
		graphics.lineStyle ( 1, 0, 0.5 );
		graphics.drawRect ( 0, 0, bannerWidth, bannerHeight );
		graphics.endFill ();

		addEventListener ( MouseEvent.CLICK, onMouseClick );

		useHandCursor = true;
		buttonMode = true;
	}

	private function onMouseClick ( event:MouseEvent ):void
	{
		if(!offers || offers[currentOfferIndex] == null) return;
		dispatchEvent ( new BannerEvent ( BannerEvent.CLICK, offers[currentOfferIndex] ) );
		navigateToURL ( new URLRequest ( services.doOffer ( offers[currentOfferIndex].id ) ) );
	}


	protected function nextOffer ():void
	{
		++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;

		playOffer ();
	}

	protected function playOffer ():void
	{
		var showEvent:BannerEvent = new BannerEvent ( BannerEvent.SHOW, offers[currentOfferIndex] );
		dispatchEvent ( showEvent );

		var reportShowToken:AsyncToken = services.reportShow ( offers[currentOfferIndex].id );

		if ( reportShowToken )
		{
			reportShowToken.target = this;
		}
	}
}
}
