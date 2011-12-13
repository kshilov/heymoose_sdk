/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/2/11
 * Time: 1:42 PM
 */
package com.heymoose.offer
{

import by.blooddy.crypto.Base64;

import com.heymoose.core.HeyMoose;
import com.heymoose.core.net.AsyncToken;
import com.heymoose.core.net.Responder;
import com.heymoose.core.ui.classes.Banner;
import com.heymoose.utils.chain.Chain;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public final class ImageBanner extends Banner
{
	private var rotateTimer:Timer;
	private var loader:Loader = new Loader ();
	private var image:DisplayObject;
	private var time:int;


	public function ImageBanner ( size:String = "0 x 0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
	{
		super ( size, backgroundColor, backgroundAlpha, services );

		loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, offerBannerLoaded );
		loader.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
		loader.contentLoaderInfo.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
	}


	public function initWithServices ( count:int = 1, timer:int = 5000 ):void
	{
		services = HeyMoose.instance;

		var chain:Chain = new Chain ( this );
		chain.addAsyncCommand ( services.introducePerformer );
		chain.addAsyncCommand ( initWithoutServices, [count, timer] );
		chain.start ();
	}


	public function initWithoutServices ( count:int = 1, timer:int = 5000 ):AsyncToken
	{
		time = timer;

		var token:AsyncToken = services.getOffers ( "1:" + count + ":" + bannerSizeId );
		token.addResponder ( new Responder ( getOffersResult, fault ) );
		return token;
	}


	override protected function getOffersResult ( result:String ):void
	{
		super.getOffersResult ( result );

		if ( !offers || offers.length == 0 ) return;

		if ( rotateTimer && rotateTimer.hasEventListener ( TimerEvent.TIMER ) )
			rotateTimer.removeEventListener ( TimerEvent.TIMER, rotateOffer );

		rotateTimer = new Timer ( time );
		rotateTimer.addEventListener ( TimerEvent.TIMER, rotateOffer );

		offers.length > 1 ? rotateTimer.start () : rotateTimer.stop ();
		playOffer ();
	}

	private function rotateOffer ( event:TimerEvent ):void
	{
		nextOffer ();
	}


	override protected function playOffer ():void
	{
		super.playOffer ();
		loader.loadBytes ( Base64.decode ( offers[currentOfferIndex].image.replace ( /[\r\n]+/g, '' ) ) );
	}


	private function offerBannerLoaded ( event:Event ):void
	{
		if ( image )
			removeChild ( image );
		image = addChild ( loader.content );
		Bitmap ( image ).smoothing = true;
		var verticalAspect:Number = (bannerHeight - 1) / image.height;
		var horizontalAspect:Number = (bannerWidth - 1) / image.width;
		if ( verticalAspect > horizontalAspect )
		{
			image.scaleX = image.scaleY = horizontalAspect;
		}
		else
		{
			image.scaleX = image.scaleY = verticalAspect;
		}
		image.x = Math.floor ( ((bannerWidth - 1) - image.width) / 2 ) + 1;
		image.y = Math.floor ( ((bannerHeight - 1) - image.height) / 2 ) + 1;
	}

	private function loader_ioErrorHandler ( event:IOErrorEvent ):void
	{
		trace ( offers[currentOfferIndex].id, event )
	}
}
}
