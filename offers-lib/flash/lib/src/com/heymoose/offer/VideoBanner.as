/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/6/11
 * Time: 11:09 AM
 */
package com.heymoose.offer
{

	import by.blooddy.crypto.serialization.JSON;

	import com.heymoose.HeyMoose;
	import com.heymoose.utils.chain.Chain;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;

	public class VideoBanner extends MovieClip
	{
		private var services:HeyMoose;
		private var offers:Array;
		private var bannerWidth:int;
		private var bannerHeight:int;
		private var time:int;
		private var video:Video;
		private var videoConnection:NetConnection;
		private var videoStream:NetStream;


		public function VideoBanner( size:String = "0 x 0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
		{
			this.services = services;
			bannerWidth = int( size.split( " x " )[0] );
			bannerHeight = int( size.split( " x " )[1] );

			graphics.beginFill( backgroundColor, backgroundAlpha );
			graphics.lineStyle( 1, 0, 0.5 );
			graphics.drawRect( 0, 0, bannerWidth, bannerHeight );
			graphics.endFill();

			addEventListener( MouseEvent.CLICK, onMouseClick );

			video = new Video();
			video.width = bannerWidth;
			video.height = bannerHeight;
			addChild( video );

			videoConnection = new NetConnection();
			videoConnection.connect( null );

			videoStream = new NetStream( videoConnection );
			videoStream.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus )

			video.attachNetStream( videoStream );

			var customClient:Object = new Object();
			customClient.onMetaData = metaDataHandler;
			customClient.onCuePoint = cuePointHandler;

			videoStream.client = customClient;
		}


		public function initWithServices( count:int = 1 ):void
		{
			services = HeyMoose.instance;

			var chain:Chain = new Chain( this );
			chain.addAsyncCommand( services.introducePerformer );
			chain.addAsyncCommand( initWithoutServices, [count] );
			chain.start();
		}


		public function initWithoutServices( count:int = 1 ):AsyncToken
		{
			var token:AsyncToken = services.getOffers( "2:" + count );
			token.addResponder( new Responder( getOffersResult, getOffersFault ) );
			return token;
		}


		private function getOffersResult( result:ResultEvent ):void
		{
			var resultObject:Object = JSON.decode( result.result.toString() );
			offers = resultObject.result;

			if ( !offers || offers.length == 0 ) return;

			playOffer()
		}


		private function getOffersFault( fault:FaultEvent ):void
		{

		}


		private var currentOfferIndex:int = 0;


		private function rotateOffer():void
		{
			++currentOfferIndex >= offers.length ? currentOfferIndex = 0 : currentOfferIndex;

			playOffer()
		}


		private function playOffer():void
		{
			videoStream.play( offers[currentOfferIndex].videoUrl );
		}


		private function onMouseClick( event:MouseEvent ):void
		{
			navigateToURL( new URLRequest( services.doOffer( offers[currentOfferIndex].id ) ) );
		}


		///////

		private function cuePointHandler( infoObject:Object ):void
		{
			trace( ObjectUtil.toString( infoObject ) );
		}


		private function metaDataHandler( infoObject:Object ):void
		{
			video.width = infoObject.width;
			video.height = infoObject.height;
			var verticalAspect:Number = (bannerHeight - 1) / infoObject.height;
			var horizontalAspect:Number = (bannerWidth - 1) / infoObject.width;
			if ( verticalAspect > horizontalAspect )
			{
				video.scaleX = video.scaleY = horizontalAspect;
			}
			else
			{
				video.scaleX = video.scaleY = verticalAspect;
			}
			video.x = Math.floor( ((bannerWidth - 1) - video.width) / 2 ) + 1;
			video.y = Math.floor( ((bannerHeight - 1) - video.height) / 2 ) + 1;
		}


		private function onNetStatus( event:NetStatusEvent ):void
		{
			video.visible = event.info.level != "error";
			if ( event.info.code == "NetStream.Play.Stop" )
			{
				rotateOffer();
			}
			if ( event.info.code == "NetStream.Play.StreamNotFound" )
			{
				rotateOffer();
			}
		}
	}
}
