/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/2/11
 * Time: 1:42 PM
 */
package com.heymoose.offer
{

import by.blooddy.crypto.Base64;

import com.heymoose.core.net.AsyncToken;
import com.heymoose.core.net.Responder;
import com.heymoose.offer.event.BannerEvent;
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


	public function ImageBanner ( size:String = "0 x 0", placeholderColor:uint = 0xFFFFFF, placeholderAlpha:Number = 0 )
	{
		super ( size, placeholderColor, placeholderAlpha );

		loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, offerBannerLoaded );
		loader.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
		loader.contentLoaderInfo.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
	}

	public function introduceAndInit ( count:int = 1, timer:int = 5000 ):void
	{
		var chain:Chain = new Chain ( this );
		chain.addAsyncCommand ( services.introducePerformer );
		chain.addAsyncCommand ( init, [count, timer] );
		chain.start ();
	}


	public function init ( count:int = 1, timer:int = 5000 ):AsyncToken
	{
		time = timer;

		var token:AsyncToken = services.getOffers ( "1:" + count + ":" + bannerSizeId );
		if(!token)
		{
			dispatchBannerError();
			return null;
		}
		token.addResponder ( new Responder ( getOffersResult ) );
		token.target = this;
		return token;
	}


	override protected function getOffersResult ( result:Object ):void
	{
		if ( !super.setOffersResult ( result ) ) return;

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

		switch ( loader.contentLoaderInfo.contentType )
		{
			case 'application/x-shockwave-flash':
				break;
			case 'image/jpeg':
				Bitmap ( image ).smoothing = true;
				break;
			case 'image/gif':
				Bitmap ( image ).smoothing = true;
				break;
		}
		var verticalAspect:Number = bannerHeight / loader.contentLoaderInfo.height;
		var horizontalAspect:Number = bannerWidth / loader.contentLoaderInfo.width;
		image.scaleX = image.scaleY = Math.min ( verticalAspect, horizontalAspect );
		image.x = (bannerWidth - loader.contentLoaderInfo.width) / 2;
		image.y = (bannerHeight - loader.contentLoaderInfo.height) / 2;
	}

	private function loader_ioErrorHandler ( event:IOErrorEvent ):void
	{
		var getOffersFaultEvent:BannerEvent = new BannerEvent ( BannerEvent.IMAGE_DECODE_ERROR, offers[currentOfferIndex] );
		dispatchEvent ( getOffersFaultEvent );
		nextOffer ();
	}

	[Deprecated(replacement="introduceAndInit", since="1.2")]
	public function initWithServices ( count:int = 1, timer:int = 5000 ):void
	{
		introduceAndInit ( count, timer );
	}

	[Deprecated(replacement="init", since="1.2")]
	public function initWithoutServices ( count:int = 1, timer:int = 5000 ):AsyncToken
	{
		return init ( count, timer )
	}
}
}
