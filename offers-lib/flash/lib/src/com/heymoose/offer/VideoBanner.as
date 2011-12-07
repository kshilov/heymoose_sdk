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

import flash.events.NetStatusEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

public class VideoBanner extends Banner
{
	private var time:int;
	private var video:Video;
	private var videoStream:NetStream;


	public function VideoBanner ( size:String = "0 x 0", backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 0.8, services:HeyMoose = null )
	{
		super ( size, backgroundColor, backgroundAlpha, services );

		video = new Video ();
		video.visible = false;
		addChild ( video );

		var videoConnection:NetConnection = new NetConnection ();
		videoConnection.connect ( null );

		videoStream = new NetStream ( videoConnection );
		videoStream.addEventListener ( NetStatusEvent.NET_STATUS, onNetStatus )

		video.attachNetStream ( videoStream );

		var customClient:Object = new Object ();
		customClient.onMetaData = metaDataHandler;
		customClient.onCuePoint = cuePointHandler;

		videoStream.client = customClient;
	}


	public function initWithServices ( count:int = 1 ):void
	{
		services = HeyMoose.instance;

		var chain:Chain = new Chain ( this );
		chain.addAsyncCommand ( services.introducePerformer );
		chain.addAsyncCommand ( initWithoutServices, [count] );
		chain.start ();
	}


	public function initWithoutServices ( count:int = 1 ):AsyncToken
	{
		var token:AsyncToken = services.getOffers ( "2:" + count );
		token.addResponder ( new Responder ( getOffersResult, fault ) );
		return token;
	}


	private function getOffersResult ( result:ResultEvent ):void
	{
		var resultObject:Object = JSON.decode ( result.result.toString () );
		offers = resultObject.result;

		if ( !offers || offers.length == 0 ) return;

		playOffer ()
	}


	override protected function playOffer ():void
	{
		super.playOffer ();
		video.visible = false;
		videoStream.play ( offers[currentOfferIndex].videoUrl );
		video.smoothing = true;
	}

	///////

	private function cuePointHandler ( infoObject:Object ):void
	{
		trace ( ObjectUtil.toString ( infoObject ) );
	}


	private function metaDataHandler ( infoObject:Object ):void
	{
		var aspectRatio:Number = infoObject.width / infoObject.height;
		var verticalAspect:Number = bannerHeight / infoObject.height;
		var horizontalAspect:Number = bannerWidth / infoObject.width;
		if ( verticalAspect > horizontalAspect )
		{
			video.width = bannerWidth;
			video.height = bannerWidth / aspectRatio;
			video.x = 1;
			video.y = ((bannerHeight) - video.height) / 2;
		}
		else
		{
			video.height = bannerHeight;
			video.width = bannerHeight * aspectRatio;
			video.y = 1;
			video.x = ((bannerWidth) - video.width) / 2;
		}

		video.visible = true;
	}


	private function onNetStatus ( event:NetStatusEvent ):void
	{
		video.visible = event.info.level != "error";
		if ( event.info.code == "NetStream.Play.Stop" )
		{
			nextOffer ();
		}
		if ( event.info.code == "NetStream.Play.StreamNotFound" )
		{
			nextOffer ();
		}
	}
}
}
