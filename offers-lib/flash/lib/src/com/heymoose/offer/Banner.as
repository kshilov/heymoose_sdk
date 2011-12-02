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
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;

	import mx.rpc.events.ResultEvent;

	public class Banner extends MovieClip
	{
		private var rotateTimer:Timer;
		private var offers:Array;
		private var services:HeyMoose;
		private var bannerWidth:int;
		private var bannerHeight:int;
		private var loader:Loader = new Loader();
		private var image:DisplayObject;
		private var time:int;

		public function Banner(size:String = "0 x 0", services:HeyMoose = null)
		{
			this.services = services;
			bannerWidth = int(size.split(" x ")[0]);
			bannerHeight = int(size.split(" x ")[1]);

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, offerBannerLoaded );

			graphics.lineStyle(1, 0, 0.5);
			graphics.drawRect(0,0,bannerWidth,bannerHeight);
		}
		public function initWithServices( count:int = 1, timer:int = 5000 ):void
		{
			services = HeyMoose.instance;

			var chain:Chain = new Chain(this);
			chain.addAsyncCommand(services.introducePerformer);
			chain.addAsyncCommand(initWithoutServices, [count, timer]);
			chain.start();
		}
		public function initWithoutServices( count:int = 1, timer:int = 5000 ):AsyncToken
		{
			time = timer;

			var token:AsyncToken = services.getOffers("1:"+count);
			token.addResponder(new Responder(getOffersResult, getOffersFault));
			return token;
		}
		private function getOffersResult(result:ResultEvent):void
		{
			var resultObject:Object = JSON.decode(result.result.toString());
			offers = resultObject.result;

			if(rotateTimer && rotateTimer.hasEventListener(TimerEvent.TIMER))
				rotateTimer.removeEventListener(TimerEvent.TIMER, rotateOffer);

			rotateTimer = new Timer(time);
			rotateTimer.addEventListener(TimerEvent.TIMER, rotateOffer);

			offers.length>1 ? rotateTimer.start() : rotateTimer.stop();
			rotateOffer(null);
		}
		private function getOffersFault(fault:FaultEvent):void
		{

		}
		private var currentOfferIndex:int = 0;
		private function rotateOffer(event:TimerEvent):void
		{
			loader.loadBytes(Base64.decode(offers[currentOfferIndex].image.replace(/[\r\n]+/g, '')));
			++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;
		}
		private function offerBannerLoaded(event:Event):void
		{
			if(image)
				removeChild(image);
			image = addChild(loader.content);
			image.x = image.y = 1;
			image.width = bannerWidth-1;
			image.height = bannerHeight-1;
		}
	}
}
