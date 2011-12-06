/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/2/11
 * Time: 1:42 PM
 */
package com.heymoose.offer
{

	import by.blooddy.crypto.Base64;
	import by.blooddy.crypto.serialization.JSON;

	import com.heymoose.HeyMoose;
	import com.heymoose.utils.chain.Chain;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;

	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class ImageBanner extends MovieClip
	{
		private var rotateTimer:Timer;
		private var offers:Array;
		private var services:HeyMoose;
		private var bannerWidth:int;
		private var bannerHeight:int;
		private var loader:Loader = new Loader();
		private var image:DisplayObject;
		private var time:int;


		public function ImageBanner( size:String = "0 x 0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
		{
			this.services = services;
			bannerWidth = int( size.split( " x " )[0] );
			bannerHeight = int( size.split( " x " )[1] );

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, offerBannerLoaded );

			graphics.beginFill( backgroundColor, backgroundAlpha );
			graphics.lineStyle( 1, 0, 0.5 );
			graphics.drawRect( 0, 0, bannerWidth, bannerHeight );
			graphics.endFill();

			addEventListener( MouseEvent.CLICK, onMouseClick );
		}


		public function initWithServices( count:int = 1, timer:int = 5000 ):void
		{
			services = HeyMoose.instance;

			var chain:Chain = new Chain( this );
			chain.addAsyncCommand( services.introducePerformer );
			chain.addAsyncCommand( initWithoutServices, [count, timer] );
			chain.start();
		}


		public function initWithoutServices( count:int = 1, timer:int = 5000 ):AsyncToken
		{
			time = timer;

			var token:AsyncToken = services.getOffers( "1:" + count );
			token.addResponder( new Responder( getOffersResult, getOffersFault ) );
			return token;
		}


		private function getOffersResult( result:ResultEvent ):void
		{
			var resultObject:Object = JSON.decode( result.result.toString() );
			offers = resultObject.result;

			if ( !offers || offers.length == 0 ) return;

			if ( rotateTimer && rotateTimer.hasEventListener( TimerEvent.TIMER ) )
				rotateTimer.removeEventListener( TimerEvent.TIMER, rotateOffer );

			rotateTimer = new Timer( time );
			rotateTimer.addEventListener( TimerEvent.TIMER, rotateOffer );

			offers.length > 1 ? rotateTimer.start() : rotateTimer.stop();
			playOffer();
		}


		private function getOffersFault( fault:FaultEvent ):void
		{

		}


		private var currentOfferIndex:int = 0;


		private function rotateOffer( event:TimerEvent ):void
		{
			++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;

			playOffer();
		}


		private function playOffer():void
		{
			loader.loadBytes( Base64.decode( offers[currentOfferIndex].image.replace( /[\r\n]+/g, '' ) ) );
		}


		private function offerBannerLoaded( event:Event ):void
		{
			if ( image )
				removeChild( image );
			image = addChild( loader.content );
			Bitmap( image ).smoothing = true;
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
			image.x = Math.floor( ((bannerWidth - 1) - image.width) / 2 ) + 1;
			image.y = Math.floor( ((bannerHeight - 1) - image.height) / 2 ) + 1;
		}


		private function onMouseClick( event:MouseEvent ):void
		{
			navigateToURL( new URLRequest( services.doOffer( offers[currentOfferIndex].id ) ) );
		}


		private function doOfferResult( event:ResultEvent ):void
		{
			trace( event );
		}
	}
}
