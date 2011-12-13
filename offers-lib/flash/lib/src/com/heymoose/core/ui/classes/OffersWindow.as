/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 9:17 AM
 */
package com.heymoose.core.ui.classes
{
import com.heymoose.core.HeyMoose;
import com.heymoose.core.OffersBase;
import com.heymoose.core.net.AsyncToken;
import com.heymoose.core.net.Responder;
import com.heymoose.core.ui.SimpleButton;
import com.heymoose.utils.chain.Chain;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class OffersWindow extends OffersBase
{
	[Embed(source="asset/skin.swf", symbol="offerWindow")]
	public var skinClass:Class;
	public var skin:Sprite;
	private var container:Sprite;

	public function OffersWindow ( services:HeyMoose )
	{
		super ( services );
		skin = new skinClass ();
		addChild ( skin );
		initButtons ();
		createContainer ();
		createScroller ();
		addEventListener ( Event.ADDED_TO_STAGE, addedToStageHandler )
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
		var token:AsyncToken = services.getOffers ( "0:" + count );
		token.addResponder ( new Responder ( getOffersResult, fault ) );
		return token;
	}

	override protected function getOffersResult ( result:String ):void
	{
		super.getOffersResult ( result );

		if ( !offers || offers.length == 0 ) return;

		var counter:int = 0;
		for each( var offer:Object in offers )
		{
			var item:OfferItem = new OfferItem ( services, offer );
			container.addChild ( item );
			item.x = 1;
			item.y = 1 + counter * (item.height + 10);
			counter++;
		}
	}

	private function initButtons ():void
	{
		var supportButton:SimpleButton = new SimpleButton ( skin['supportButton'] );
		var cancelButton:SimpleButton = new SimpleButton ( skin['cancelButton'] );
		var scrollDownButton:SimpleButton = new SimpleButton ( skin['scrollDown'] );
		var scrollUpButton:SimpleButton = new SimpleButton ( skin['scrollUp'] );

		scrollDownButton.addEventListener ( MouseEvent.CLICK, scrollDownButton_clickHandler );
		scrollUpButton.addEventListener ( MouseEvent.CLICK, scrollUpButton_clickHandler );

		supportButton.addEventListener ( MouseEvent.CLICK, helpButton_click );
		cancelButton.addEventListener ( MouseEvent.CLICK, closeButton_click );
	}

	private var conatinerMask:Sprite;

	private function createContainer ():void
	{
		conatinerMask = skin['maskClip'];
		container = new Sprite ();
		container.x = conatinerMask.x;
		container.y = conatinerMask.y;
		container.mask = conatinerMask;
		addChild ( container );
	}

	private var scrollBack:Sprite;
	private var scrollThumb:Sprite;
	private var minScrollPosition:int;
	private var maxScrollPosition:int;

	private function createScroller ():void
	{
		scrollBack = skin['scrollBack'];
		scrollThumb = skin['scrollThumb'];
		minScrollPosition = scrollThumb.y;
		maxScrollPosition = scrollBack.height - scrollThumb.height + 1;
		scrollThumb.addEventListener ( MouseEvent.MOUSE_DOWN, thumb_MouseDown );
		scrollThumb.addEventListener ( MouseEvent.MOUSE_UP, thumb_MouseUp );

		dragRectangle = new Rectangle ();
		dragRectangle.x = scrollBack.x;
		dragRectangle.y = scrollBack.y - 1;
		dragRectangle.width = 0;
		dragRectangle.height = scrollBack.height - scrollThumb.height + 1;
	}

	private var scrollThumbDragging:Boolean = false;
	private var dragRectangle:Rectangle;

	private function thumb_MouseDown ( event:MouseEvent ):void
	{
		scrollThumb.startDrag ( false, dragRectangle );
		scrollThumbDragging = true;
	}

	private function thumb_MouseUp ( event:MouseEvent ):void
	{
		scrollThumb.stopDrag ();
		scrollThumbDragging = false;
	}

	private function addedToStageHandler ( event:Event ):void
	{
		stage.addEventListener ( MouseEvent.MOUSE_UP, thumb_MouseUp );
		stage.addEventListener ( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
	}

	private function stage_mouseMoveHandler ( event:MouseEvent ):void
	{
		if ( scrollThumbDragging )
		{
			refreshScrollPosition ()
		}
	}

	private function refreshScrollPosition ():void
	{
		var scrollFactor:Number = (scrollThumb.y - minScrollPosition) / maxScrollPosition;
		container.y = conatinerMask.y - scrollFactor * (container.height - conatinerMask.height);
	}

	private function scrollUpButton_clickHandler ( event:MouseEvent ):void
	{
		scrollThumb.y -= container.height / 100;
		if ( scrollThumb.y < dragRectangle.top ) scrollThumb.y = dragRectangle.top;
		refreshScrollPosition ()
	}

	private function scrollDownButton_clickHandler ( event:MouseEvent ):void
	{
		scrollThumb.y += container.height / 100;
		if ( scrollThumb.y > dragRectangle.bottom ) scrollThumb.y = dragRectangle.bottom;
		refreshScrollPosition ()
	}

	private function helpButton_click ( e:MouseEvent ):void
	{
		navigateToURL ( new URLRequest ( "http://heymoose.com/contacts" ), "_blank" );
	}


	private function closeButton_click ( e:MouseEvent ):void
	{
		this.visible = true;
		dispatchEvent ( new Event ( Event.CLOSE ) );
	}
}
}
