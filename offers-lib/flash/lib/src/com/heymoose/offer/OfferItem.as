/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 9:17 AM
 */
package com.heymoose.offer
{
import by.blooddy.crypto.Base64;

import com.heymoose.core.HeyMoose;
import com.heymoose.offer.event.BannerEvent;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

internal class OfferItem extends Sprite
{
	[Embed(source="asset/skin.swf", symbol="offer")]
	public var skinClass:Class;
	public var skin:Sprite;

	private var loader:Loader = new Loader ();
	private var image:DisplayObject;

	protected var services:HeyMoose;
	protected var data:Object;

	public function OfferItem ( services:HeyMoose, data:Object )
	{
		this.services = services;
		this.data = data;

		skin = new skinClass ();
		addChild ( skin );

		skin['header'].text = data.title;
		skin['text'].text = data.description;

		loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, offerBannerLoaded );
		loader.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
		loader.contentLoaderInfo.addEventListener ( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );

		loader.loadBytes ( Base64.decode ( data.image.replace ( /[\r\n]+/g, '' ) ) );
		buttonMode = true;
		useHandCursor = true;

		addEventListener ( MouseEvent.CLICK, onMouseClick )
	}

	private function offerBannerLoaded ( event:Event ):void
	{
		if ( image )
			removeChild ( image );
		image = skin.addChild ( loader.content );
		Bitmap ( image ).smoothing = true;
		image.width = skin['imageMask'].width;
		image.height = skin['imageMask'].height;
		image.x = skin['imageMask'].x;
		image.y = skin['imageMask'].y;
		image.mask = skin['imageMask'];
		skin.swapChildren ( image, skin['imageMask'] )
	}

	private function loader_ioErrorHandler ( event:IOErrorEvent ):void
	{
		var getOffersFaultEvent:BannerEvent = new BannerEvent ( BannerEvent.IMAGE_DECODE_ERROR );
		dispatchEvent ( getOffersFaultEvent );
	}

	private function onMouseClick ( event:MouseEvent ):void
	{
		dispatchEvent ( new BannerEvent ( BannerEvent.CLICK, data ) );
		navigateToURL ( new URLRequest ( services.doOffer ( data.id ) ) );
	}
}
}
