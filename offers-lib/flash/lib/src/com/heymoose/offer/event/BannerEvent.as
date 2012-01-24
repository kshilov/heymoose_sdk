/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/7/11
 * Time: 8:42 PM
 */
package com.heymoose.offer.event
{
import flash.events.Event;

public class BannerEvent extends Event
{
	// Dispatch on banner show
	public static const SHOW:String = "com.heymoose.offer.event.show";

	// Dispatch when offers list empty
	public static const OFFERS_LIST_EMPTY:String = "com.heymoose.offer.event.offersListEmpty";
	// Dispatch on offers loading faulted
	public static const GET_OFFERS_FAULT:String = "com.heymoose.offer.event.getOffersFault";

	// Dispatch on decode image error
	public static const IMAGE_DECODE_ERROR:String = "com.heymoose.offer.event.offerDisplayError";

	// Offers clicked
	public static const CLICK:String = "com.heymoose.offer.event.click";
	// Window closed
	public static const CLOSE_WINDOW:String = "com.heymoose.offer.event.closeWindow";

	public var offer:Object;

	public function BannerEvent ( type:String, offer:Object = null, bubbles:Boolean = true )
	{
		this.offer = offer;
		super ( type, bubbles )
	}
}
}
