/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/7/11
 * Time: 8:18 PM
 */
package com.heymoose.offer
{
import by.blooddy.crypto.serialization.JSON;

import com.heymoose.HeyMoose;
import com.heymoose.offer.event.BannerEvent;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public class Banner extends MovieClip
{
	protected var bannerWidth:int;
	protected var bannerHeight:int;
	protected var bannerSizeId:String;
	protected var offers:Array;
	protected var services:HeyMoose;

	protected var currentOfferIndex:int = 0;

	public function Banner ( size:String = "0x0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
	{
		this.services = services;
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

	private function getOffersResult ( result:ResultEvent ):void
	{
		var resultObject:Object = JSON.decode ( result.result.toString () );
		offers = resultObject.result;

		if ( !offers || offers.length == 0 ) return;
	}

	protected function fault ( fault:FaultEvent ):void
	{

	}

	protected function nextOffer ():void
	{
		++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;

		playOffer ();
	}

	protected function playOffer ():void
	{
		dispatchEvent ( new BannerEvent ( BannerEvent.SHOW, offers[currentOfferIndex], true ) );
	}
}
}
